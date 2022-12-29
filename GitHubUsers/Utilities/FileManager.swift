//
//  FileManager.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 28/12/2022.
//

import Foundation

/// File exist check status
public enum FileExist {
    /// File exist at the location specified.
    case exist
    /// Directory exist at the location specified.
    case isDirectory
    /// No file or directory exist at the location specified.
    case notExist
}

/// `URL` to the cache directory in the app sandbox.
public var cacheDirectoryUrl: URL {
    let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
    let url = urls[0]

    return url
}

/// `URL` to a temporary directory in app sandbox.
public var temporaryDirectory: URL { FileManager.default.temporaryDirectory }

/// Make a `URL` to a unique file or directory name in the temporary directory of the app sandbox.
///
/// The temporary name generated will be regenerated if the name exists on the temporary directory of the app sandbox.
/// This function does not create the file
/// or directory.
/// - Returns: `URL` to the temporary file/directory name in the temporary directory of the app sandbox.
public func makeTemporaryFileUrl() -> URL {
    var tmpUrl = temporaryDirectory.appendingPathComponent(UUID().uuidString, conformingTo: .fileURL)

    while fileExist(url: tmpUrl) != .notExist {
        tmpUrl = temporaryDirectory.appendingPathComponent(UUID().uuidString, conformingTo: .fileURL)
    }

    return tmpUrl
}

/// Create directory at `URL`.
///
/// If `directory` exist, this function will do nothing. This function re-throw all errors thrown from the `FileManager` instance.
/// - Parameters:
///   - directory: `URL` to the directory to be created.
public func create(directory: URL) throws {
    if fileExist(url: directory) == .notExist {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
    }
}

/// Check if file or directory exist.
///
/// This functions returns one of the `FileExist` status. See `FileExist` enum for more information.
///
/// - Note: Attempting to predicate behavior based on the current state of the file system or a particular file on the file system
/// is not recommended. Doing so can cause odd behavior or race conditions. Usage for this function should be limited to getting
/// the filesystem states that are not obtainable via other `FileManager` operations.
/// - Parameters:
///   - url: `URL` to the file or directory to check if exist.
/// - Returns: `FileExist` status
public func fileExist(url: URL) -> FileExist {
    var isDirectory: ObjCBool = false
    let exist = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)

    if !exist {
        return .notExist

    } else if isDirectory.boolValue {
        return .isDirectory

    }

    return .exist
}

/// Safer move file or directory from source to destination.
///
/// Move file operation will attempt to overwrite the destination file if exist. If the parent directory at the destination does not exist,
/// this function will create it before moving the source file(s). If the destination is a directory this function will not overwritten the
/// directory unless the `overwriteDirectory` is set to true. In the case where the destination is a directory and the
/// `overwriteDirectory` is set to false, the function throws and error. This function will throw if errors occurs during the move
/// operation that the move function could not determine the corrective action.
/// - Parameters:
///   - from: `URL` to the source file or directory.
///   - to: `URL` to the destination file or directory.
///   - overwriteDirectory: `Bool` to allow overwriting directory if set to true.
public func move(from source: URL, to destination: URL, overwriteDirectory: Bool = false) throws {

    let fileManager = FileManager.default
    let trashUrl = makeTemporaryFileUrl()

    // Bail if destination exist and is a directory unless overwriteDirectory is true.
    if fileExist(url: destination) == .isDirectory && !overwriteDirectory {
        let description = "Could not overwrite destination \(destination.path) because it is a directory."
        let userInfo: [ String : Any ] = [ NSLocalizedDescriptionKey : description ]

        let error = NSError(domain: CocoaError.errorDomain,
                            code: CocoaError.Code.fileWriteFileExists.rawValue,
                            userInfo: userInfo)

        throw error
    }

    // Create containing directory at destination if the containing directory does not exist.
    let containingDirectory = destination.deletingLastPathComponent()
    try create(directory: containingDirectory)

    // Move destination file if exist to the temporary directory so that:
    // - Makes the move operation atomic where if the move failed, the original file can
    //   be restored.
    // - Moving the destination file out of the way before the actual move has lower chance
    //   of failure compared to attempt to overwrite on the move operation.
    do {
        try fileManager.moveItem(at: destination, to: trashUrl)

    } catch let error as NSError {
        // Ignore error if error is file does not exist. Otherwise re-throw the error.
        if error.code != NSFileNoSuchFileError {
            let isExist = fileExist(url: destination)
            if isExist == .exist || isExist == .isDirectory {
                throw error
            }
        }
    }

    // Do the actual move
    do {
        try fileManager.moveItem(at: source, to: destination)

    } catch let error as NSError {
        // Move operation has failed. Restore original file if any.
        // At this point, the error to restore the file is ignored because it can be:
        // - The destination file never existed before the move.
        // - There is no good recovery strategy at this point.
        try? fileManager.moveItem(at: trashUrl, to: destination)

        throw error
    }

    // Finally, remove the old destination file if exist.
    try? fileManager.removeItem(at: trashUrl)
}

/// Safer remove file or directory.
///
/// If the given `url` is to a resource that does not exist on the filesystem, this function will do nothing. Otherwise the file
/// or directory is move to a `tmp` directory in the app sandbox before carrying out the remove operation. If the remove
/// operation failed, the file or directory is left in the `tmp` directory and the operation is deem successful. This function
/// will throw if errors occurs during the remove operation that the remove function could not determine the corrective
/// action.
/// - Parameters:
///   - url: URL to the file or directory to be removed.
public func remove(url: URL) throws {
    let fileManager = FileManager.default
    let trashUrl = makeTemporaryFileUrl()

    do {
        try fileManager.moveItem(at: url, to: trashUrl)
        try fileManager.removeItem(at: trashUrl)

    } catch let error as NSError {
        if error.code != NSFileNoSuchFileError {
            throw error
        }
    }
}

