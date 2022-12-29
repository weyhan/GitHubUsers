//
//  FooterTableViewCell.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 27/12/2022.
//

import UIKit

class FooterTableViewCell: UITableViewCell, HomeFooterTableViewCell {

    /// View model for the NoteCellViewModel
    var viewModel: FooterCellViewModel!

    @IBOutlet var spinner: UIActivityIndicatorView!

    /// Setup footer cell with a view model.
    func setup(withViewModel viewModel: HomeFooterCellViewModelProtocol) {
        guard let viewModel = viewModel as? FooterCellViewModel else {
            fatalError("viewModel is not FooterCellViewModel")
        }

        self.viewModel = viewModel

        if !viewModel.isSearchMode {
            spinner.startAnimating()

        } else {
            spinner.stopAnimating()
        }
    }

}
