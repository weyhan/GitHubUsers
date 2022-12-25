//
//  HomeViewModel.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 25/12/2022.
//

import Foundation

/// Methods for triggering UI changes and refresh from view model.
///
/// Use the methods of this protocol to manage the following features:
/// - Showing and hiding status bar.
/// - Refresh table view after data changes.
protocol HomeViewDelegate: AnyObject {
    func showStatus(text: String)
    func hideStatus()
    func reloadData()
}

/// View model for Home screen.
class HomeViewModel {

    /// The object that acts as the delegate of the view.
    ///
    /// The delegate must adopt the HomeViewDelegate protocol. The delegate isn’t retained.
    weak var delegate: HomeViewDelegate?

    /// The number of elements of users record cached in persistent store.
    var count: Int {
        return GitHubUser.count()
    }

    /// Asks the data source for a cell view model for a particular location of the table view.
    func cellViewModel(forRowAt row: Int) -> HomeCellViewModel {
        let fetchRequest = GitHubUser.fetchRequest()
        let predicate = NSPredicate(format: "row == \(row)")

        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1

        guard let user = try? CoreDataStack.shared.mainContext.fetch(fetchRequest).first,
              let homeCellViewModel = makeCellViewModel(row, user: user) else {

            return NormalCellViewModel(login: "-", details: "-")
        }

        return homeCellViewModel
    }

    /// Make view model for cell.
    private func makeCellViewModel(_ row: Int, user: GitHubUser) -> HomeCellViewModel? {

        switch viewModelType(forRowAt: row) {
        case .normal:
            return NormalCellViewModel(login: user.login, details: user.type)

        case .note:
            return NoteCellViewModel(login: user.login, details: user.type)

        default:
            return nil
        }

    }

    /// Determine the view model type.
    ///
    /// The view model type depends on the following:
    /// - Does the GitHub user have a note attached to their records.
    /// - Should the profile image be inverted.
    /// Each of the criteria will determine if the cell is with or without ornament and if yes it's of which types.
    private func viewModelType(forRowAt row: Int) -> HomeCellType {
        // TODO: Get from persistent store if user have note stored.
//        let hasNote = false
//
//        if hasNote {
//            return .note
//        }

        return .normal
    }

}
