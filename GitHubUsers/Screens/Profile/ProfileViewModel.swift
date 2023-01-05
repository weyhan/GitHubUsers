//
//  ProfileModel.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 02/01/2023.
//

import Foundation

/// View model for the profile view.
class ProfileViewModel: ObservableObject, ProfileViewModelProtocol {
    /// State of the profile view.
    enum State {
        /// Initial state where no data is loaded yet.
        case idle
        /// Loading state where data is fetching from remote.
        case loading
        /// Failed to load data from remote.
        case failed(Error)
        /// Data loaded from remote.
        case loaded(GitHubUser)
    }

    @Published private(set) var state: State = .idle

    private var login: String
    private var id: Int
    private var row: Int

    /// Profile data for user
    var profile: GitHubUser! {
        didSet {
            set(state: .loaded(self.profile))
        }
    }

    init(row: Int, id: Int64, login: String) {
        self.login = login
        self.id = Int(id)
        self.row = row
    }

    /// Set the state of the profile view.
    ///
    /// State is always set in main thread to ensure any view update is performed in the main thread.
    /// - Parameters:
    ///   - state: The state of the profile view of type `State`
    private func set(state: State) {
        DispatchQueue.main.async { self.state = state }
    }

    /// Method to trigger loading profile data from remote.
    func loadData() {
        set(state: .loading)
        loadGitHubUserProfile(login: login)
    }

    /// Method to load profile data from cache.
    private func loadCachedProfile() {
        guard let user = GitHubUser.fetchUser(atRow: row) else {
            return
        }

        profile = user
    }

    /// Method to load profile data from remote.
    ///
    /// - Parameters:
    ///   - login: The login ID of the user profile to load.
    private func loadGitHubUserProfile(login: String) {
        let url = GitHubEndpoints.userProfile(forLogin: login)

        let dataTask = NetworkDataTask(remoteUrl: url, session: URLSession.shared) { [weak self] result in
            guard let self = self else { return }

            NetworkQueue.shared.release()

            switch result {
            case .success(let data):
                self.decodeGitHubUsersProfile(data: data, row: self.row)

            case .failure(let error):
                self.set(state: .failed(error))
            }

        }

        let queue = NetworkQueue.shared
        queue.enqueue(networkJob: dataTask)
        queue.resume()
    }
}

extension ProfileViewModel {

    /// Convenient method to decodes results from GitHub user profile API.
    ///
    /// Setup completion closure to handle decode success and failure.
    /// - Parameters:
    ///   - data: Raw JSON data.
    ///   - row: The profile row in relation with the Home screen table view row.
    private func decodeGitHubUsersProfile(data: Data, row: Int) {

        decode(data: data, row: row) { decodeResult in
            switch decodeResult {
            case .success:
                // Data successfully decoded and saved in cache. Proceed to load data from
                // saved cached data for display.
                self.loadCachedProfile()

            case .failure(_):
                let error = DecodingError.errorDescription("Decode JSON Error")
                self.set(state: .failed(error))
            }
        }

    }

    /// Method to decodes results from GitHub user profile API.
    ///
    /// - Parameters:
    ///   - data: Raw JSON data.
    ///   - row: The profile row in relation with the Home screen table view row.
    ///   - coreDataStack: The CoreData stack to use for saving the decoded result.
    ///   - completion: The closure to call with Result of failure or success.
    private func decode(data: Data, row: Int, coreDataStack: CoreDataStack = CoreDataStack.shared, completion: @escaping (DecodingVoidResult)->()) {

        let context = coreDataStack.backgroundContext()

        context.perform {
            let decoder = JSONDecoderService<GitHubUser>(context: context, coreDataStack: coreDataStack)

            let user: GitHubUser
            do {
                user = try decoder.decode(data: data)

            } catch {
                completion(.failure(DecodingError.errorDescription(error.localizedDescription)))
                return
            }

            user.row = Int64(row)
            coreDataStack.saveContextAndWait(context)

            completion(.success)
        }
    }

}

