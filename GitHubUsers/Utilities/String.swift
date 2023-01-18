//
//  String.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 04/01/2023.
//

import Foundation

/// Prepares optional `Strings` for display
///
/// Optional `String` is unwrapped into either the string content or into "-" if optional string is nil or
/// empty.
/// - Parameters:
///   - string: An optional string that will be displayed.
/// - Returns: String ready for display on UI.
public func displayText(_ string: String?) -> String {
    string == nil || string?.isEmpty == true ? "-" : string!
}

/// Prepares optional `Int` for display
///
/// Optional `Int` is unwrapped and converted to either the string content or to "-" if optional `Int` is nil.
/// - Parameters:
///   - string: An optional string that will be displayed.
///   - withGroupingSeparator: Boolean to flag if output number should have group-seperators.
/// - Returns: String ready for display on UI.
public func displayText(_ integer: Int?, withGroupingSeparator: Bool = true) -> String {
    guard let integer = integer else {
        return "-"
    }

    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    let number = NSNumber(value: integer)
    return formatter.string(from: NSNumber(value: integer)) ?? "-"
}
