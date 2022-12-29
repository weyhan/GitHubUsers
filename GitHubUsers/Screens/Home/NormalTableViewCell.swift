//
//  NormalTableViewCell.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 25/12/2022.
//

import UIKit

class NormalTableViewCell: HomeTableViewCell, HomeTableViewCellProtocol {

    @IBOutlet var login: UILabel!
    @IBOutlet var details: UILabel!
    @IBOutlet var avatar: UIImageView!

    /// Setup UITableViewCell with a view model.
    ///
    /// This method should only be called from the table view cell for row delegate method in `UITableView`.`
    func setup(withViewModel viewModel: HomeCellViewModelProtocol) {
        self.viewModel = viewModel
        self.viewModel.delegate = self

        login.text = viewModel.login
        details.text = viewModel.details

        avatar.image = avatarImage
    }

    /// Updates avatar image.
    ///
    /// Avatar image will be loaded from cache if available. If the avatar image is not cached, this method will request
    /// the view model to download the  avatar image and will load the generic avatar image while the avatar image is
    /// downloaded. This method will not wait for the image to be downloaded and instead will rely on the view model
    /// to call this method again when the image is available.
    func updateAvatar() {
        avatar.image = avatarImage
    }

}
