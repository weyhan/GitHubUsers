//
//  NormalTableViewCell.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 25/12/2022.
//

import UIKit

class NormalTableViewCell: UITableViewCell, HomeTableViewCell {

    /// View model for the NormalCellViewModel
    var viewModel: NormalCellViewModel!

    @IBOutlet var login: UILabel!
    @IBOutlet var details: UILabel!

    /// Setup UITableViewCell with a view model.
    func setup(withViewModel viewModel: HomeCellViewModel) {
        guard let viewModel = viewModel as? NormalCellViewModel else {
            fatalError("viewModel is not NormalCellViewModel")
        }

        login.text = viewModel.login
        details.text = viewModel.details

        self.viewModel = viewModel
    }

}
