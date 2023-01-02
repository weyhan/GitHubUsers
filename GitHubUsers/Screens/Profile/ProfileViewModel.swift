//
//  ProfileModel.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 02/01/2023.
//

import Foundation

class ProfileViewModel: ObservableObject, ProfileViewModelProtocol {
    enum State {
        case idle
        case loading
        case failed(Error)
        case loaded(GitHubUser)
    }

    @Published private(set) var state: State = .idle

    private var login: String
    private var id: Int
    private var row: Int

    var profile: GitHubUser! {
        didSet {
            DispatchQueue.main.async {
                self.state = .loaded(self.profile)
            }
        }
    }

    init(row: Int, id: Int64, login: String) {
        self.login = login
        self.id = Int(id)
        self.row = row
    }

    func loadData() {
        state = .loading
        loadGitHubUserProfile(login: login)
    }

    private func updateProfile() {
        guard let user = GitHubUser.fetchUser(atRow: row) else {
            return
        }

        profile = user
    }

    func loadGitHubUserProfile(login: String) {
        let url = GitHubEndpoints.userProfile(forLogin: login)

        let dataTask = NetworkDataTask(remoteUrl: url, session: URLSession.shared) { [weak self] result in
            guard let self = self else { return }

            NetworkQueue.shared.release()
            switch result {

            case .success(let data):
                self.decodeGitHubUsersProfile(data: data, row: self.row, coreDataStack: CoreDataStack.shared) { decodeResult in
                    if case .success(_) = decodeResult {
                        self.updateProfile()

                    } else {
                        self.state = .failed(DecodingError.errorDescription("Decode JSON Error"))
                    }
                }

            case .failure(let error):
                self.state = .failed(error)
            }

        }

        let queue = NetworkQueue.shared
        queue.enqueue(networkJob: dataTask)
        queue.resume()
    }
}

extension ProfileViewModel {

    /// Decodes results from GitHub user profile API.
    private func decodeGitHubUsersProfile(data: Data, row: Int, coreDataStack: CoreDataStack, completion: @escaping (Result<GitHubUser, DecodingError>)->()) {

        let context = coreDataStack.backgroundContext()

        context.perform {
            let decoder = JSONDecoderService<GitHubUser>(context: context, coreDataStack: coreDataStack)

            let user: GitHubUser
            do {
                user = try decoder.decode(data: data)

            } catch {
                completion(.failure(error as! DecodingError))
                return
            }

            user.row = Int64(row)
            coreDataStack.saveContextAndWait(context)

            completion(.success(user))
        }
    }

}

extension ProfileViewModel {
    var avatarImageUrl: URL {
        Cache.avatarImageFileUrl(forId: id)
    }
}
