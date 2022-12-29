//
//  NetworkDownloadTask.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 29/12/2022.
//

import Foundation

/// Object to download remove file.
class NetworkDownloadTask: NetworkQueueable {

    let task: URLSessionDownloadTask

    var queueDelegate: NetworkQueue?

    /// Initializer for the NetworkDownloadTask.
    ///
    /// Setup URLRequest and URLSessionDownloadTask to receive response and call completion with Result failure or
    /// success with data.
    /// - Parameters:
    ///   - remoteUrl: The endpoint for the network API to call.
    ///   - localFileUrl: The location to save the downloaded file.
    ///   - session: The URLSession instance to use for the network call.
    ///   - completion: Closure to call with Result of failure or success with data from the network call.
    init(remoteUrl: URL, localFileUrl: URL, session: URLSession, completion: @escaping NetworkQueueDownloadTaskCompletion) {

        let request = URLRequest(url: remoteUrl)

        task = session.downloadTask(with: request) { tempFileUrl, response, error in

            if let error = error as? NSError {
                completion(.failure(NetworkError.mapping(code: error.code)))
                return
            }

            guard let tempFileUrl = tempFileUrl else {
                completion(.failure(.missingFile))
                return
            }

            do {
                try move(from: tempFileUrl, to: localFileUrl)

            } catch {
                completion(.failure(.saveFileFailed))
                return
            }

            completion(.success)
        }
    }

    /// Start network download task
    func resume() {
        task.resume()
    }
}
