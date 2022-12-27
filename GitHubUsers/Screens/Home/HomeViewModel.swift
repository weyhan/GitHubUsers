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
    func refreshUI()
}

/// View model for Home screen.
class HomeViewModel {

    /// The object that acts as the delegate of the view.
    ///
    /// The delegate must adopt the HomeViewDelegate protocol. The delegate isn’t retained.
    weak var delegate: HomeViewDelegate?

    /// The number of elements of users record cached in persistent store.
    var count: Int {
        if isSearchMode {
            let count = searchResult?.count ?? 0
            showStatus(text: "Matched \(count) user(s)")
            return count
        }

        return GitHubUser.count()
    }

    var isSearchMode = false
    var searchResult: [GitHubUser]?

    private var footerCellViewModel = FooterCellViewModel()

    // MARK: - UI Delegates Calls

    /// Method to refresh UI.
    ///
    /// - Note: Call to UI delegate is always called on the main thread.
    private func refreshUI() {
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.refreshUI()
        }
    }

    /// Method to show status bar with certain text.
    ///
    /// - Note: Call to UI delegate is always called on the main thread.
    private func showStatus(text: String) {
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.showStatus(text: text)
        }
    }

    /// Method to dismiss status bar.
    ///
    /// - Note: Call to UI delegate is always called on the main thread.
    private func hideStatus() {
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.hideStatus()
        }
    }

    // MARK: - Cell View Model Methods

    /// Asks the data source for a cell view model for a particular location of the table view.
    func cellViewModel(forRowAt row: Int) -> HomeCellViewModel {
        if isSearchMode {
            return cellViewModelSearchMode(row)
        }

        return cellViewModelNormalMode(row)
    }

    /// Get normal view model for search mode.
    private func cellViewModelSearchMode(_ row: Int) -> HomeCellViewModel {
        guard let user = searchResult?[row] else {
            fatalError("Search result don't match count!")
        }

        return NormalCellViewModel(login: user.login, details: user.type)
    }

    /// Get cell view model for normal mode.
    private func cellViewModelNormalMode(_ row: Int) -> HomeCellViewModel {
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

    /// Get footer cell view model.
    func cellViewModelForFooter() -> FooterCellViewModel {
        return footerCellViewModel
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

    // MARK: - JSON Decoding Methods

    /// Decodes results from GitHub user list API.
    private func decodeGitHubUsersList(data: Data, lastIndex: Int, coreDataStack: CoreDataStack, completion: @escaping (Result<[GitHubUser], DecodingError>)->()) {

        var row = lastIndex
        let context = coreDataStack.backgroundContext()

        context.perform {
            let decoder = JSONDecoderService<[GitHubUser]>(context: context, coreDataStack: coreDataStack)

            let users: [GitHubUser]
            do {
                users = try decoder.decode(data: data)

            } catch {
                completion(.failure(error as! DecodingError))
                return
            }

            users.forEach { row += 1; $0.row = Int64(row) }
            coreDataStack.saveContextAndWait(context)

            completion(.success(users))
        }
    }

    // MARK: - Network Tasks

    /// Load new data from GitHub users list API.
    ///
    /// Request for the list of users starting from the next ID after the last user ID cached. Results are JSON decoded
    /// and cached in persistent store.
    func loadNewData() {
        guard isSearchMode == false else { return }
        let lastId = GitHubUser.lastId()
        loadGitHubUsers(afterId: lastId)
    }

    /// Load data from GitHub user list API.
    ///
    /// Request for the list of users starting from the next ID after the given `afterId`.
    /// - Parameters:
    ///   - afterId: Request for the list of users starting from the next ID following `afterId`.
    func loadGitHubUsers(afterId: Int) {
        let url = GitHubEndpoints.userList(afterId: afterId)

        let dataTask = NetworkDataTask(remoteUrl: url, session: URLSession.shared) { [unowned self] result in

            if case .success(let data) = result {
                decodeGitHubUsersList(data: data,
                                      lastIndex: GitHubUser.count() - 1,
                                      coreDataStack: CoreDataStack.shared) { decodeResult in

                    if case .success(_) = decodeResult {
                        self.refreshUI()
                    }
                }
            }

        }

        dataTask.resume()
    }
}

extension HomeViewModel {

    /// Turn on or off search mode.
    ///
    /// Search mode is determined by the `forSearchText` argument. Search mode will be turned on
    /// if `forSearchText` is not `nil` and not empty.
    /// - Parameters:
    ///   - forSearchText: Text use to filter result for the user search.
    func filterUser(forSearchText text: String?) {
        if let text = text, !text.isEmpty {
            enterSearchMode(text)

        } else {
            exitSearchMode()
        }
    }

    /// Cleanups for exit search mode
    private func exitSearchMode() {
        /// The search controller tend to call the updateSearchResults method multiple times
        /// when cancelling the search. Because the exit search mode cleanups refresh the UI
        /// doing multiple cleanups may cause the UI to be less smooth.

        // Check if in search mode before proceeding with cleanups.
        guard isSearchMode else { return }

        isSearchMode = false
        footerCellViewModel.isSearchMode = false
        hideStatus()
        delegate?.refreshUI()

        return
    }

    /// Setup for search mode.
    ///
    /// - Parameters:
    ///   - text: Text use to filter result for the user search.
    private func enterSearchMode(_ text: String) {
        let request = GitHubUser.fetchRequest()

        request.predicate = NSPredicate(format: "login CONTAINS[cd] %@", argumentArray: [text])
        searchResult = try? CoreDataStack.shared.mainContext.fetch(request)

        isSearchMode = true
        footerCellViewModel.isSearchMode = true
        delegate?.refreshUI()
    }
}
