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
    var avatar: AvatarImage? { get }

    var reuseIdentifier: String { get }

    var delegate: HomeTableViewCellProtocol! { get set }

    var isAvatarColorInverted: Bool { get }

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

    var avatar: AvatarImage?

    var delegate: HomeTableViewCellProtocol!

    /// Initializes view model.
    init(id: Int64, login: String, details: String, avatarUrl: String, row: Int64) {
        let id = Int(id)
        let row = Int(row)

        self.id = id
        self.login = login
        self.details = details
        self.avatarUrl = avatarUrl
        self.row = row

        self.avatar = AvatarImage(id: id, remoteUrlString: avatarUrl, invertColor: isAvatarColorInverted)
    }

    /// Boolean to indicate if the avatar image color should be inverted.
    ///
    /// Decide if row should be inverted based on `row` and `invertedRowDistance`.
    var isAvatarColorInverted: Bool {
        // Normalized by +1 to row (row starts at 0 instead of 1).
        (row + 1) % AppConstants.invertedRowDistance == 0
    }

    /// Release view model when associated cell is reused for another row.
    func prepareForReuse() {
        avatar?.cancel()
        avatar = nil
        delegate = nil
    }
}
