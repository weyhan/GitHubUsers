//
//  NetworkDataTask.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 19/12/2022.
//

import Foundation

/// Object to call a network API with a given URL to the network endpoint and returns data from the response.
class NetworkDataTask: NetworkQueueable {

    let task: URLSessionDataTask

    var queueDelegate: NetworkQueue?

    /// Initializer for the NetworkDataTask.
    ///
    /// Setup URLRequest and URLSessionDataTask to receive response and call completion with Result failure or success with
    /// data.
    /// - Parameters:
    ///   - remoteUrl: The endpoint for the network API to call.
    ///   - session: The URLSession instance to use for the network call.
    ///   - completion: Closure to call with Result of failure or success with data from the network call.
    init(remoteUrl: URL, session: URLSession, completion: @escaping NetworkQueueCompletion) {

        let request = URLRequest(url: remoteUrl)

        task = session.dataTask(with: request) { data, response, error in

            if let error = error as? NSError {
                completion(.failure(NetworkError.mapping(code: error.code)))
                return
            }

            guard let data = data else {
                completion(.failure(.missingData))
                return
            }

            completion(.success(data))
        }
    }

    /// Start network data task
    func resume() {
        task.resume()
    }
}
