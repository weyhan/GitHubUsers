//
//  NetworkTasksSupport.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 19/12/2022.
//

import Foundation

enum NetworkVoidResult {
    case success
    case failure(NetworkError)
}

typealias NetworkQueueDataTaskCompletion = (Result<Data, NetworkError>)->()
typealias NetworkQueueDownloadTaskCompletion = (NetworkVoidResult)->()

/// Internal error code from errors returned from URLSession network calls.
enum NetworkError: Error {
    /// Network operation is cancelled.
    case cancelled
    /// Network operation timeout.
    case timeout
    /// Network operation returns `nil` or empty data.
    case missingData
    /// Network download file operation returns successful but file is missing.
    case missingFile
    /// Network download file operation successful but saving the downloaded file failed.
    case saveFileFailed
    /// Network operation returns unspecified error.
    ///
    /// Unspecified errors are errors that have not been considered to handle at this point.
    case unspecifiedError
    /// The exact error is unknown.
    case unknownError

    /// Map error code to `NetworkError`.
    static func mapping(code: Int) -> NetworkError {
        return errorCodeMapping(code: code)
    }
}

/// Maps error code from NSURLSession suit to internal error code.
///
/// Errors are grouped when it make sense in the app level but could also be mapped one to one with an internal
/// error code. This mapping will grow as needed.
fileprivate func errorCodeMapping(code: Int) -> NetworkError {
    switch code {
    case NSURLErrorCancelled:
        return .cancelled

    case NSURLErrorTimedOut:
        return .timeout

    default:
        return .unspecifiedError
    }
}

extension URLSessionConfiguration {

    /// A URLSessionConfiguration object defaults specific to this app.
    static var appDefault: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 60

        return config
    }

}
