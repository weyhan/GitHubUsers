//
//  NoteTableViewCell.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 25/12/2022.
//

import UIKit

class NoteTableViewCell: UITableViewCell, HomeTableViewCell {

    /// View model for the NoteCellViewModel
    var viewModel: NoteCellViewModel!

    @IBOutlet var login: UILabel!
    @IBOutlet var details: UILabel!

    /// Setup UITableViewCell with a view model.
    func setup(withViewModel viewModel: HomeCellViewModel) {
        guard let viewModel = viewModel as? NoteCellViewModel else {
            fatalError("viewModel is not NoteCellViewModel")
        }

        login.text = viewModel.login
        details.text = viewModel.details

        self.viewModel = viewModel
    }

}
