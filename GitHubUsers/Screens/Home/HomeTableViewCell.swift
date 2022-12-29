//
//  HomeTableViewCell.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 26/12/2022.
//

import UIKit

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
    func updateAvatar()
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

    /// Prepares a reusable cell for reuse by the table view’s delegate.
    override func prepareForReuse() {
        super.prepareForReuse()

        viewModel.prepareForReuse()
        viewModel = nil
    }

    /// The avatar image.
    ///
    /// Avatar image will be loaded from cache if available. If the avatar image is not cached, this computed property will
    /// request the view model to download the  avatar image and will load the generic avatar image while the avatar
    /// image is downloaded.
    var avatarImage: UIImage {
        guard let imageData = viewModel.loadAvatarImageData(),
              let image = UIImage(data: imageData) else {

            // If the load image results in error, assume image has not been downloaded
            // or cached image file is corrupted.
            viewModel.downloadAvatarImage()
            return AppConstants.defaultAvatarImage
        }

        if viewModel.isAvatarColorInverted {
            if let invertedImage = image.invertColor() {
                return invertedImage
            }
        }

        return image
    }

}
