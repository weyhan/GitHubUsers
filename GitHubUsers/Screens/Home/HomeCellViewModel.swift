//
//  HomeCellViewModel.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 26/12/2022.
//

import Foundation

/// Properties and methods for managing and configuring the UITableViewCell.
protocol HomeCellViewModelProtocol {
    var id: Int { get }
    var login: String { get }
    var details: String { get }
    var avatarUrl: String { get }

    var reuseIdentifier: String { get }

    var delegate: HomeTableViewCellProtocol! { get set }

    var isAvatarColorInverted: Bool { get }

    func downloadAvatarImage()
    func loadAvatarImageData() -> Data?

    func prepareForReuse()
}

/// Properties and methods for managing and configuring the footer cell.
protocol HomeFooterCellViewModelProtocol {
    var reuseIdentifier: String { get }
}

class HomeCellViewModel {

    let id: Int
    let login: String
    let details: String
    let avatarUrl: String
    let row: Int

    var delegate: HomeTableViewCellProtocol!

    private var fileDownloadTask: NetworkDownloadTask? = nil

    /// Initializes view model.
    init(id: Int64, login: String, details: String, avatarUrl: String, row: Int64) {
        self.id = Int(id)
        self.login = login
        self.details = details
        self.avatarUrl = avatarUrl
        self.row = Int(row)
    }

    /// Boolean to indicate if the avatar image color should be inverted.
    ///
    /// Decide if row should be inverted based on `row` and `invertedRowDistance`.
    var isAvatarColorInverted: Bool {
        // Normalized by +1 to row (row starts at 0 instead of 1).
        (row + 1) % AppConstants.invertedRowDistance == 0
    }

    /// Setup and queue network download task for downloading avatar image.
    func downloadAvatarImage() {
        guard let url = URL(string: avatarUrl) else {
            return
        }

        let cacheFileUrl = Cache.avatarImageFileUrl(forId: id)

        let fileDownloadTask = NetworkDownloadTask(remoteUrl: url, localFileUrl: cacheFileUrl, session: URLSession.shared) { [weak self] result in
            NetworkQueue.shared.release()

            switch result {
            case .success:
                self?.updateAvatar()
                break

            case .failure(_):
                break
            }
        }

        self.fileDownloadTask = fileDownloadTask

        let queue = NetworkQueue.shared
        queue.enqueue(networkJob: fileDownloadTask)
        queue.resume()
    }

    /// Method to update avatar image after avatar image is downloaded.
    ///
    /// - Note: Call to UI delegate is always called on the main thread.
    func updateAvatar() {
        DispatchQueue.main.async { [weak self] in
            self?.delegate.updateAvatar()
        }
    }

    /// Load avatar image into `Data` from file.
    func loadAvatarImageData() -> Data? {
        return try? Data(contentsOf: Cache.avatarImageFileUrl(forId: id))
    }

    /// Release view model when associated cell is reused for another row.
    func prepareForReuse() {
        fileDownloadTask?.cancel()
        fileDownloadTask = nil
        delegate = nil
    }
}
