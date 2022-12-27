//
//  HomeTableViewCell.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 26/12/2022.
//

import Foundation

enum HomeCellType {
    case normal
    case note
    case error
}

/// Methods for managing and configuring the table view cell on the Home screen.
///
/// Use the methods of this protocol to manage the following features:
/// - Setup table view cells on the Home screen table view.
protocol HomeTableViewCell {
    func setup(withViewModel viewModel: HomeCellViewModel)
}

/// Methods for managing and configuring the table view footer cell on the Home screen.
///
/// Use the methods of this protocol to manage the following features:
/// - Setup table view the footer cell on the Home screen table view.
protocol HomeFooterTableViewCell {
    func setup(withViewModel viewModel: HomeFooterCellViewModel)
}
