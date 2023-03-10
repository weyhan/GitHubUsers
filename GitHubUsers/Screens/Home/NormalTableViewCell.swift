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

        outerBox.layer.borderColor = UIColor(named: "borderColor")?.cgColor

        viewModel.additionalSetup()
    }

    /// Set cell for dim apparance.
    func dimCell() {
        login.isEnabled = false
        details.isEnabled = false
        avatarImageView.alpha = 0.5
    }

    /// Prepares a reusable cell for reuse by the table view’s delegate.
    override func prepareForReuse() {
        super.prepareForReuse()

        login.isEnabled = true
        details.isEnabled = true
        avatarImageView.alpha = 1.0
    }
}
