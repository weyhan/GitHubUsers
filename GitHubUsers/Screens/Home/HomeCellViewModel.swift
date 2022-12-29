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

    var delegate: HomeTableViewCell! { get set }

    func downloadAvatarImage()
    func loadAvatarImageData() -> Data?
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

    var usersPath = "users"
    var avatarPath = "avatar"
    var avatarFilename = "avatar"

    var delegate: HomeTableViewCell!

    init(id: Int64, login: String, details: String, avatarUrl: String) {
        self.id = Int(id)
        self.login = login
        self.details = details
        self.avatarUrl = avatarUrl
    }


    func avatarImageFileUrl(forId id: Int) -> URL {
        cacheDirectoryUrl
            .appendingPathComponent(usersPath, conformingTo: .directory)
            .appendingPathComponent("\(id)", conformingTo: .directory)
            .appendingPathComponent(avatarPath, conformingTo: .directory)
            .appendingPathComponent(avatarFilename, conformingTo: .fileURL)
            .appendingPathExtension("image")
    }

    func downloadAvatarImage() {
        guard let url = URL(string: avatarUrl) else {
            return
        }

        let cacheFileUrl = avatarImageFileUrl(forId: id)

        let downloader = NetworkDownloadTask(remoteUrl: url, localFileUrl: cacheFileUrl, session: URLSession.shared) { [unowned self] result in
            NetworkQueue.shared.release()

            switch result {
            case .success:
                updateAvatar()
                break

            case .failure(_):
                break
            }
        }

        let queue = NetworkQueue.shared
        queue.enqueue(networkJob: downloader)
        queue.resume()
    }

    func updateAvatar() {
        DispatchQueue.main.async { [unowned self] in
            delegate.updateAvatar()
        }
    }

    func loadAvatarImageData() -> Data? {
        return try? Data(contentsOf: avatarImageFileUrl(forId: id))
    }
}
