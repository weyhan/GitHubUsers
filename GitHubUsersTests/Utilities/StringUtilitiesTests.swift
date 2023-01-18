//
//  StringUtilitiesTests.swift
//  GitHubUsersTests
//
//  Created by WeyHan Ng on 18/01/2023.
//

import XCTest
@testable import GitHubUsers

final class StringUtilitiesTests: XCTestCase {

    func testDisplayTextForStrings() throws {
        let nilString: String? = nil
        let displayNilString = displayText(nilString)

        XCTAssertTrue(displayNilString == "-")

        let string = "String to display."
        let displayString = displayText(string)

        XCTAssertTrue(displayString == string)
    }

    func testDisplayTextForInt() throws {
        let nilInt: Int? = nil
        let displayNilIntString = displayText(nilInt)

        XCTAssertTrue(displayNilIntString == "-")

        let int1 = 5
        let displayIntString1 = displayText(int1)

        XCTAssertTrue(displayIntString1 == "5")
        XCTAssertTrue(true)

        let int2 = 50000
        let displayIntString2 = displayText(int2)

        XCTAssertTrue(displayIntString2 == "50,000")
        XCTAssertTrue(true)
    }

}
