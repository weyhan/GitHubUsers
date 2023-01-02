//
//  Cache.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 03/01/2023.
//

import UIKit

struct Cache {

    /// `URL` to the cached avatar image file.
    ///
    /// The `URL` is constructed based on convention `<cache dir>/user/<id>/avatar/avatar.image`.
    /// - Parameters:
    ///   - forId: The ID of the avatar image's owner.
    static func avatarImageFileUrl(forId id: Int) -> URL {
        cacheDirectoryUrl
            .appendingPathComponent(AvatarPathComponent.userDirectory, conformingTo: .directory)
            .appendingPathComponent("\(id)", conformingTo: .directory)
            .appendingPathComponent(AvatarPathComponent.avatarDirectory, conformingTo: .directory)
            .appendingPathComponent(AvatarPathComponent.filename, conformingTo: .fileURL)
            .appendingPathExtension("image")
    }

    /// Load cached image file if available.
    ///
    /// Load cached image file, If the image file is cached for user ID from `forId`, otherwise returns nil.
    /// - Parameters:
    ///   - forId: The GitHub user ID.
    /// - Returns: UIImage object or nil.
    static func loadCachedImage(forId id: Int) -> UIImage? {
        let url = avatarImageFileUrl(forId: id)
        guard let image = UIImage(contentsOfFile: url.path) else {
            return nil
        }

        return image
    }
}
