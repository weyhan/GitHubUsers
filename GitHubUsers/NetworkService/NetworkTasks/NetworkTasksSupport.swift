//
//  NetworkTasksSupport.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 19/12/2022.
//

import Foundation

typealias NetworkQueueCompletion = (Result<Data, NetworkError>)->()

/// Internal error code from errors returned from URLSession network calls.
enum NetworkError: Error {
    case cancelled
    case missingData
    case unspecifiedError
    case unknownError

    static func mapping(code: Int) -> NetworkError {
        return errorCodeMapping(code: code)
    }
}

/// Maps error code from NSURLSession suit to internal error code.
///
/// Errors are grouped when it make sense in the app level but could also be mapped one to one with an internal
/// error code. **unspecifiedError** is the catch all mapping group that on the app level could not handle or
/// have not been considered to handle at this point. This mapping will grow as needed.
fileprivate func errorCodeMapping(code: Int) -> NetworkError {
    switch code {
    case NSURLErrorCancelled:
        return .cancelled

    default:
        return .unspecifiedError
    }
}
