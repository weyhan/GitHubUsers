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
func displayText(_ string: String?) -> String {
    string == nil || string?.isEmpty == true ? "-" : string!
}

/// Prepares optional `NSDecimalNumber` for display
///
/// Optional `NSDecimalNumber` is unwrapped and converted to either the string content or to "-" if optional `NSDecimalNumber` is nil.
/// - Parameters:
///   - string: An optional string that will be displayed.
/// - Returns: String ready for display on UI.
func displayText(_ decimalNumber: NSDecimalNumber?) -> String {
    decimalNumber != nil ? "\(decimalNumber!)" : "-"
}
