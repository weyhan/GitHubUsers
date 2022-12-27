//
//  FooterCellViewModel.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 27/12/2022.
//

import Foundation

/// The view model for the footer cell.
///
/// The footer cell is the last cell after the last loaded user. The footer cell displays an activity indicator and
/// triggers new data loading on normal mode.
class FooterCellViewModel: HomeFooterCellViewModel {

    var reuseIdentifier = "FooterCell"

    var isSearchMode = false
}
