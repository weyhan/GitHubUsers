//
//  UserDefaults.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 19/01/2023.
//

import Foundation

private var _pageLength: Int? = nil
private let pageLengthKey = "pageLength"

/// The number of profile for every call to the GitHubUser list API.
public var pageLength: Int? {
    get {
        if let length = _pageLength {
            return length
        }
        let length = UserDefaults.standard.integer(forKey: pageLengthKey)
        return length == 0 ? nil : length
    }

    set {
        UserDefaults.standard.set(newValue, forKey: pageLengthKey)
        _pageLength = newValue
    }
}
