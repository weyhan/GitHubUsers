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
    @IBOutlet var avatarImageView: UIImageView!

    @IBOutlet var outerBox: UIView!

    /// Setup UITableViewCell with a view model.
    ///
    /// This method should only be called from the table view cell for row delegate method in `UITableView`.`
    func setup(withViewModel viewModel: HomeCellViewModelProtocol) {
        self.viewModel = viewModel
        self.viewModel.delegate = self

        login.text = viewModel.login
        details.text = viewModel.details

        guard let avatar = viewModel.avatar else {
            fatalError("HomeCellViewModelProtocol is misconfigured.")
        }
        self.avatar = avatar

        bindAvatarImage() { [weak self] image in
            self?.avatarImageView.image = image
        }

        avatar.loadAvatarFile()

        outerBox.layer.borderColor = UIColor.gray.cgColor
    }

}
