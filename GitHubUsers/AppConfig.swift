//
//  AppConfig.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 19/12/2022.
//

import UIKit

/// Constants for PersistentStore
struct PersistentStore {
    static let modelName = "GitHubUsers"
    static let entityName = "GitHubUser"
}

/// Misc app related constants.
struct AppConstants {
    /// Name of the default avatar image as in the Assets catalogue.
    static let defaultProfileImageName = "DefaultProfileImage"

    /// Preloaded default avatar image as `UIImage`.
    static let defaultAvatarImage = UIImage(named: AppConstants.defaultProfileImageName)!

    /// Distance between color inverted avatar rows.
    ///
    /// Constant to the distance between color inverted avatar rows. e.g. if set to "4", every 4th rows will need to apply invert
    /// color filter to the avatar image.
    static let invertedRowDistance = 4
}
