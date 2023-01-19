//
//  NetworkDataTask.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 19/12/2022.
//

import Foundation

/// Object to call a network API with a given URL to the network endpoint and returns data from the response.
class NetworkDataTask: NSObject, NetworkQueueable {

    var task: URLSessionDataTask!

    var queueDelegate: NetworkQueue?

    /// Initializer for the NetworkDataTask.
    ///
    /// Setup URLRequest and URLSessionDataTask to receive response and call completion with Result failure or success with
    /// data.
    /// - Parameters:
    ///   - remoteUrl: The endpoint for the network API to call.
    ///   - session: The URLSession instance to use for the network call.
    ///   - completion: Closure to call with Result of failure or success with data from the network call.
    init(remoteUrl: URL, completion: @escaping NetworkQueueDataTaskCompletion) {
        super.init()

        let request = URLRequest(url: remoteUrl)

        let config = URLSessionConfiguration.appDefault
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)

        task = session.dataTask(with: request) { data, response, error in
            session.finishTasksAndInvalidate()

            if let error = error as? NSError {
                let networkError = NetworkError.mapping(code: error.code)

                if networkError != .timeout && networkError != .cancelled {
                    NetworkState.shared.set(networkState: .connectedToInternetEstablished)
                }
                completion(.failure(networkError))

                return
            }

            NetworkState.shared.set(networkState: .connectedToInternetEstablished)

            guard let data = data else {
                completion(.failure(.missingData))
                return
            }

            completion(.success(data))
        }
    }

    /// Start network data task.
    func resume() {
        task.resume()
    }

    /// Cancel network data task.
    func cancel() {
        task.cancel()
    }
}

extension NetworkDataTask: URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        NetworkState.shared.set(networkState: .notConnectedToInternet)
    }

}
