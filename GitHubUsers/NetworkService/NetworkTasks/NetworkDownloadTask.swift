//
//  NetworkDownloadTask.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 29/12/2022.
//

import Foundation

/// Object to download remove file.
class NetworkDownloadTask: NSObject, NetworkQueueable {

    var task: URLSessionDownloadTask!

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
    init(remoteUrl: URL, localFileUrl: URL, completion: @escaping NetworkQueueDownloadTaskCompletion) {
        super.init()

        let request = URLRequest(url: remoteUrl)

        let config = URLSessionConfiguration.appDefault
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)

        task = session.downloadTask(with: request) { tempFileUrl, response, error in
            session.finishTasksAndInvalidate()

            if let error = error as? NSError {
                let networkError = NetworkError.mapping(code: error.code)

                if networkError != .timeout {
                    NetworkState.shared.set(networkState: .connectedToInternetEstablished)
                }
                completion(.failure(networkError))

                return
            }

            NetworkState.shared.set(networkState: .connectedToInternetEstablished)

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

    /// Start network download task.
    func resume() {
        task.resume()
    }

    /// Cancel network download task.
    func cancel() {
        task.cancel()
    }
}

extension NetworkDownloadTask: URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        NetworkState.shared.set(networkState: .notConnectedToInternet)
    }

}
