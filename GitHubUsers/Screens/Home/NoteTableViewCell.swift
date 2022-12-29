//
//  NoteTableViewCell.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 25/12/2022.
//

import UIKit

class NoteTableViewCell: UITableViewCell, HomeTableViewCell {

    var viewModel: HomeCellViewModelProtocol!

    @IBOutlet var login: UILabel!
    @IBOutlet var details: UILabel!
    @IBOutlet var avatarImage: UIImageView!
    
    /// Setup UITableViewCell with a view model.
    func setup(withViewModel viewModel: HomeCellViewModelProtocol) {
        login.text = viewModel.login
        details.text = viewModel.details

        self.viewModel = viewModel
        self.viewModel.delegate = self

        viewModel.downloadAvatarImage()
    }

    func updateAvatar() {
        guard let imageData = viewModel.loadAvatarImageData() else {
            return
        }

        avatarImage.image = UIImage(data: imageData)
    }

}
