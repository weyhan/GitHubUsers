//
//  PagingControl.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 19/01/2023.
//

import Foundation

/// An object to control page load.
public final class PagingControl {
    static let shared = PagingControl()
    private init() { }

    private var pageLoaded: [Int] = []

    @Published private(set) var loadingPage: Int = 0

    var isReady: Bool {
        pageLength != nil
    }

    var length: Int {
        pageLength ?? -1
    }

    /// Set the page length.
    ///
    /// The page length are only set the first time and will persist across session until the app is clean reinstalled.
    /// - Parameters:
    ///   - pageLength: The length of the page to set in persistent store.
    func set(pageLength length: Int) {
        if pageLength == nil {
            // If pageLength is set for the first time, the first page have to be loaded.
            pageLoaded.append(0)
            pageLength = length
        }
    }

    /// Inform paging control of page loading desire..
    ///
    /// Paging control may broadcast desire to load page on the following condition:
    /// - The page length is known.
    /// - Row is the first row of a page based on the known page length.
    /// - The page is not previously loaded in the current session.
    /// - Parameters:
    ///   - atRow: The row number requesting the load.
    func requestLoading(atRow row: Int) {
        guard let length = pageLength else {
            return
        }

        if row % length == 0 && pageLoaded.firstIndex(of: row) == nil {
            pageLoaded.append(row)
            loadingPage = row

            return
        }
    }


}

