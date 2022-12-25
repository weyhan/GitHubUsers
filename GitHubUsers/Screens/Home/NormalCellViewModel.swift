//
//  NormalCellViewModel.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 25/12/2022.
//

import Foundation

/// The view model for normal cells.
///
/// The normal cell is the basic cell type on the home screen where there is no extra ornament.
class NormalCellViewModel: HomeCellViewModel {

    let reuseIdentifier = "NormalCell"

    let login: String
    let details: String

    init(login: String, details: String) {
        self.login = login
        self.details = details
    }

}
