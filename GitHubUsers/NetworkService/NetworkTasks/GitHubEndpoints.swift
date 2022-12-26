//
//  GitHubEndpoints.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 26/12/2022.
//

import Foundation

/// Methods to compose and URLs for GitHub API calls.
struct GitHubEndpoints {

    /// Compose the URL to the GitHub API to retrieve a list of users.
    /// - Parameters:
    ///   - afterId: Request for the list of users starting from the next ID following `afterId`.
    static func userList(afterId since: Int) -> URL {
        var urlComponent = URLComponents()
        urlComponent.scheme = "https"
        urlComponent.host = "api.github.com"
        urlComponent.path = "/users"
        urlComponent.queryItems = [ URLQueryItem(name: "since", value: "\(since)") ]

        return urlComponent.url!
    }

}
