//
//  AvatarImage.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 04/01/2023.
//

import UIKit

/// Errors relating to `AvatarImage` class.
enum AvatarImageError: Error {
    case errorDescription(String)
}

/// The avatar image model.
class AvatarImage: ObservableObject {
    @Published private(set) var image: UIImage?
    @Published private(set) var error: AvatarImageError?

    private let id: Int
    private let remoteUrl: URL?
    private var fileDownloadTask: NetworkDownloadTask? = nil

    convenience init(id: Int64, remoteUrlString: String) {
        self.init(id: Int(id), remoteUrlString: remoteUrlString)
    }

    init(id: Int, remoteUrlString: String) {
        self.id = id
        self.remoteUrl = URL(string: remoteUrlString)
    }

    /// Load avatar image.
    ///
    /// Loads the cached avatar image if available on cache. In the case where the image file is not cached or
    /// the file could not be loaded for whatever reason, this function will attempt to download the avatar via
    /// GitHub's API.
    func loadAvatarFile() {
        guard let image = Cache.loadCachedImage(forId: id) else {
            image = AppConstants.defaultAvatarImage
            downloadAvatarImage()

            return
        }

        self.image = image
    }

    /// Download avatar image.
    ///
    /// Downloaded avatar image file is moved to cache. If download is successful, the image file is loaded as UIImage. Successful or failure
    /// status is broadcast to entity subscribed to `image` or `error` property respectively.
    func downloadAvatarImage() {
        let cacheFileUrl = Cache.avatarImageFileUrl(forId: id)

        guard let remoteUrl = remoteUrl else { return }

        let fileDownloadTask = NetworkDownloadTask(remoteUrl: remoteUrl, localFileUrl: cacheFileUrl) { [weak self] result in
            NetworkQueue.shared.release()

            guard let self = self else { return }

            switch result {
            case .success:
                guard let image = Cache.loadCachedImage(forId: self.id) else { return }
                self.image = image

            case .failure(_):
                self.error = AvatarImageError.errorDescription("Failed to download avatar.")
            }
        }

        self.fileDownloadTask = fileDownloadTask

        let queue = NetworkQueue.shared
        queue.enqueue(networkJob: fileDownloadTask)
        queue.resume()
    }

    /// Cancel download task.
    func cancel() {
        fileDownloadTask?.cancel()
        fileDownloadTask = nil
    }

}
