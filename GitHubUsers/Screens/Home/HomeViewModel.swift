//
//  HomeViewModel.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 25/12/2022.
//

import Foundation
import Combine

/// Methods for triggering UI changes and refresh from view model.
///
/// Use the methods of this protocol to manage the following features:
/// - Showing and hiding status bar.
/// - Refresh table view after data changes.
protocol HomeViewDelegate: AnyObject {
    func showStatus(text: String)
    func hideStatus()
    func refreshUI()
    func refresh(rowAt row: Int)
}

/// View model for Home screen.
class HomeViewModel {

    /// The object that acts as the delegate of the view.
    ///
    /// The delegate must adopt the HomeViewDelegate protocol. The delegate is not retained.
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
    private var cancellable: Set<AnyCancellable> = []

    /// HomeViewModel initializer.
    init() {
        // Setup observing network state.
        NetworkState.shared.$networkState.sink { [weak self] networkState in
            switch networkState {
            case .notConnectedToInternet:
                self?.showStatus(text: "No Internet Connection")

            case .connectedToInternetEstablished:
                self?.hideStatus()
            }
        }.store(in: &cancellable)
    }

}

// MARK: - UI Delegates Calls Extension
extension HomeViewModel {

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

}

// MARK: - Cell View Model Methods Extension
extension HomeViewModel {

    /// Asks the data source for a cell view model for a particular location of the table view.
    func cellViewModel(forRowAt row: Int) -> HomeCellViewModelProtocol {
        if isSearchMode {
            return cellViewModelSearchMode(row)
        }

        return cellViewModelNormalMode(row)
    }

    /// Get footer cell view model.
    func cellViewModelForFooter() -> FooterCellViewModel {
        return footerCellViewModel
    }

    /// Get normal view model for search mode.
    private func cellViewModelSearchMode(_ row: Int) -> HomeCellViewModelProtocol {
        guard let user = searchResult?[row] else {
            fatalError("Search result don't match count!")
        }

        return NormalCellViewModel(id: user.intId, login: user.login, details: user.type, avatarUrl: user.avatarUrl, row: user.intRow, lastViewed: user.lastViewed)
    }

    /// Get cell view model for normal mode.
    private func cellViewModelNormalMode(_ row: Int) -> HomeCellViewModelProtocol {
        guard let user = GitHubUser.fetchUser(atRow: row),
              let homeCellViewModel = makeCellViewModel(row, user: user) else {

            fatalError("Cached profiles don't match count!")
        }

        return homeCellViewModel
    }

    /// Make view model for cell.
    private func makeCellViewModel(_ row: Int, user: GitHubUser) -> HomeCellViewModelProtocol? {
        switch viewModelType(forUser: user) {
        case .normal:
            return NormalCellViewModel(id: user.intId, login: user.login, details: user.type, avatarUrl: user.avatarUrl, row: user.intRow, lastViewed: user.lastViewed)

        case .note:
            return NoteCellViewModel(id: user.intId, login: user.login, details: user.type, avatarUrl: user.avatarUrl, row: user.intRow, lastViewed: user.lastViewed)

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
    private func viewModelType(forUser user: GitHubUser) -> HomeCellType {
        let isNoted = user.notes?.text != nil

        if isNoted {
            return .note
        }

        return .normal
    }

    /// Handles did select row on user list table view.
    ///
    /// Fetch user profile from cached user profiles and present profile screen with user profile data.
    /// - Parameters:
    ///   - row: The row number selected.
    func didSelectRowAt(row: Int) {
        let user = isSearchMode ? searchResult?[row] : GitHubUser.fetchUser(atRow: row)

        guard let user = user else {
            fatalError("Home UITableView is misconfigured.")
        }

        guard let viewController = delegate as? SwiftUIPresentable else {
            fatalError("Home UITableView is misconfigured.")
        }
        
        let profileViewModel = ProfileViewModel(id: user.intId, login: user.login)
        profileViewModel.homeViewModel = delegate
        let profileView = ProfileView(viewModel: profileViewModel)

        SwiftUIPresenter.present(viewController: viewController, swiftUIView: profileView)
    }

}

// MARK: - JSON Decoding Methods Extension
extension HomeViewModel {

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

            users.forEach { row += 1; $0.intRow = row }
            coreDataStack.saveContextAndWait(context)

            completion(.success(users))
        }
    }

}

// MARK: - Network Tasks Extension
extension HomeViewModel {

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

        let dataTask = NetworkDataTask(remoteUrl: url) { [unowned self] result in

            NetworkQueue.shared.release()

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

        let queue = NetworkQueue.shared
        queue.enqueue(networkJob: dataTask)
        queue.resume()
    }
}

// MARK: - Search Mode Extension
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
        searchResult = nil
        hideStatus()
        refreshUI()

        return
    }

    /// Setup for search mode.
    ///
    /// - Parameters:
    ///   - text: Text use to filter result for the user search.
    private func enterSearchMode(_ text: String) {
        // Search in both properties, `login` and `notes.text`.
        let predicates = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "login CONTAINS[cd] %@", argumentArray: [text]),
            NSPredicate(format: "notes.text CONTAINS[cd] %@", argumentArray: [text])
        ])

        searchResult = GitHubUser.fetchUsers(predicates: predicates)

        isSearchMode = true
        footerCellViewModel.isSearchMode = true
        refreshUI()
    }
}
