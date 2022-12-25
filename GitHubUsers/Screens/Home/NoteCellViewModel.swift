//
//  NoteCellViewModel.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 25/12/2022.
//

import Foundation

/// The view model for note cells.
///
/// The note cell has a note icon to indicate that the user have an attached note on record.
class NoteCellViewModel: HomeCellViewModel {

    let reuseIdentifier = "NoteCell"

    let login: String
    let details: String

    init(login: String, details: String) {
        self.login = login
        self.details = details
    }

}
