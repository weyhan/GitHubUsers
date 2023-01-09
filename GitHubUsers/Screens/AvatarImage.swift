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

    private var isColorInverted: Bool
    private var fileDownloadTask: NetworkDownloadTask? = nil

    /// Initializer for `AvatarImage`
    ///
    /// - Parameters:
    ///   - id: The GitHub user ID.
    ///   - remoteUrlString: A string representation of a URL pointing to GitHub user's avatar image.
    ///   - invertColor: The flag to indicate if the image should be color inverted on the display. Defaults to false.
    init(id: Int, remoteUrlString: String, invertColor: Bool = false) {
        self.id = id
        self.remoteUrl = URL(string: remoteUrlString)
        self.isColorInverted = invertColor
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

        set(image: image)
    }

    /// Method to set loaded image to image property.
    ///
    /// The image is color inverted if the `isColorInverted` flag is set to `true`.
    /// - Parameters:
    ///   - image: The `UIImage` object of the GitHub user's avatar loaded from cache.
    private func set(image: UIImage?) {
        guard let image = image else { return }
        self.image = isColorInverted ? image.invertColor() : image
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
                self.set(image: Cache.loadCachedImage(forId: self.id))

            case .failure(_):
                self.error = AvatarImageError.errorDescription("Failed to download avatar.")
            }
        }

        self.fileDownloadTask = fileDownloadTask

        let queue = NetworkQueue.shared
        queue.enqueue(networkJob: fileDownloadTask)
        queue.resume()
    }

    /// Method to cancel download task if task is still active.
    func cancel() {
        fileDownloadTask?.cancel()
        fileDownloadTask = nil
    }

}
