//
//  HomeTableViewCell.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 26/12/2022.
//

import UIKit
import Combine

enum HomeCellType {
    case normal
    case note
    case error
}

/// Methods for managing and configuring the table view cell on the Home screen.
///
/// Use the methods of this protocol to manage the following features:
/// - Setup table view cells on the Home screen table view.
protocol HomeTableViewCellProtocol {
    func setup(withViewModel viewModel: HomeCellViewModelProtocol)
}

/// Methods for managing and configuring the table view footer cell on the Home screen.
///
/// Use the methods of this protocol to manage the following features:
/// - Setup table view the footer cell on the Home screen table view.
protocol HomeFooterTableViewCellProtocol {
    func setup(withViewModel viewModel: HomeFooterCellViewModelProtocol)
}

class HomeTableViewCell: UITableViewCell {

    var viewModel: HomeCellViewModelProtocol!

    private var cancellable: Set<AnyCancellable> = []

    var avatar: AvatarImage!

    /// Prepares a reusable cell for reuse by the table view’s delegate.
    override func prepareForReuse() {
        super.prepareForReuse()

        viewModel.prepareForReuse()
        viewModel = nil
    }

    /// Setup to observe the avatar image object.
    ///
    /// Setup to execute the handler closure when the image property in `AvatarImage` object changed.
    func bindAvatarImage(handler: @escaping (UIImage?)->()) {
        avatar.$image.sink { image in
            DispatchQueue.main.async { handler(image) }
        }.store(in: &cancellable)
    }

}
