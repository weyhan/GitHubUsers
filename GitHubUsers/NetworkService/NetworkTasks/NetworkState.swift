//
//  NetworkState.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 17/01/2023.
//

import Foundation

enum NetworkStateCode {
    /// Connection to the Internet established.
    case connectedToInternetEstablished
    /// Not connected to the Internet.
    case notConnectedToInternet
}

class NetworkState {
    static let shared = NetworkState()

    @Published private(set) var networkState: NetworkStateCode = .connectedToInternetEstablished

    func set(networkState: NetworkStateCode) {
        if self.networkState != networkState {
            self.networkState = networkState
        }
    }
}
