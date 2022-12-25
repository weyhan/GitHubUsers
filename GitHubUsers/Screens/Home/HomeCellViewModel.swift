//
//  HomeCellViewModel.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 26/12/2022.
//

import Foundation

/// Properties and methods for managing and configuring the UITableViewCell.
protocol HomeCellViewModel {
    var login: String { get }
    var details: String { get }

    var reuseIdentifier: String { get }
}
