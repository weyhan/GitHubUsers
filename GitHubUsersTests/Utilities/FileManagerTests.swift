//
//  FileManagerTests.swift
//  GitHubUsersTests
//
//  Created by WeyHan Ng on 25/01/2023.
//

import XCTest
@testable import GitHubUsers

final class FileManagerTests: XCTestCase {

    var testDirectoryUrl: URL!

    override func setUpWithError() throws {
        let fileManager = FileManager.default

        // Create test space in the sandbox tmp directory.
        testDirectoryUrl = fileManager.temporaryDirectory.appending(path: UUID().uuidString)
        try fileManager.createDirectory(at: testDirectoryUrl, withIntermediateDirectories: true)
    }
    

    override func tearDownWithError() throws {
        // Clean up test space.
        do {
            try FileManager.default.removeItem(at: testDirectoryUrl)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }

    /// Test the fileExist function.
    ///
    /// Test fileExist for conditions as follows:
    /// - File exist and it's a directory.
    /// - File exist and it's not a directory.
    /// - File does not exist.
    func testFileExist() throws {
        // Test condition: File exist and it's a directory.
        let testDirectoryExist = fileExist(url: testDirectoryUrl)
        XCTAssertTrue(testDirectoryExist == .isDirectory, "Failed to get existence state for directory.")

        // Test condition: File does not exist.
        let testFileUrl = testDirectoryUrl.appending(path: "testfile.txt")
        let testFileNotExist = fileExist(url: testFileUrl)
        XCTAssertTrue(testFileNotExist == .notExist)

        // Test condition: File exist and it's not a directory.
        try UUID().uuidString.write(toFile: testFileUrl.path, atomically: true, encoding: .utf8)
        let testFileExist = fileExist(url: testFileUrl)
        XCTAssertTrue(testFileExist == .exist)
    }

    /// Test create directory function.
    func testCreateDir() throws {
        let fileManager = FileManager.default

        // Setup test condition.
        let dirUrl = testDirectoryUrl.appending(path: UUID().uuidString)

        var isDirectory: ObjCBool = false
        let existBefore = fileManager.fileExists(atPath: dirUrl.path, isDirectory: &isDirectory)

        XCTAssertFalse(existBefore, "Improper setup")

        // Test starts.
        try create(directory: dirUrl)

        // Assert file exist and it is a directory.
        isDirectory = false
        let existAfter = fileManager.fileExists(atPath: dirUrl.path, isDirectory: &isDirectory)
        XCTAssertTrue(existAfter && isDirectory.boolValue, "Failed to create directory")
    }

    /// Test create directory where parent directory does not exist.
    func testCreateDirWithParents() throws {
        let fileManager = FileManager.default

        // Setup test condition.
        let dir1Url = testDirectoryUrl.appending(path: UUID().uuidString)
        let dir2Url = dir1Url.appending(path: UUID().uuidString)

        var isDirectory: ObjCBool = false
        let exist1Before = fileManager.fileExists(atPath: dir1Url.path, isDirectory: &isDirectory)
        let exist2Before = fileManager.fileExists(atPath: dir2Url.path, isDirectory: &isDirectory)

        guard exist1Before == false, exist2Before == false else {
            XCTFail("Improper setup")
            return
        }

        // Test starts.
        try create(directory: dir2Url)

        // Assert parent directory exist after creation.
        isDirectory = false
        let exist1After = fileManager.fileExists(atPath: dir1Url.path, isDirectory: &isDirectory)
        XCTAssertTrue(exist1After && isDirectory.boolValue, "Failed to create directory with parents")

        // Assert directory exist after creation.
        isDirectory = false
        let exist2After = fileManager.fileExists(atPath: dir2Url.path, isDirectory: &isDirectory)
        XCTAssertTrue(exist2After && isDirectory.boolValue, "Failed to create directory with parents")
    }

    /// Test move file function.
    ///
    /// Test moving file overwriting destination file..
    func testMoveFileOverwrite() throws {
        let fileManager = FileManager.default

        // Setup test condition.
        let testContent1 = UUID().uuidString
        let testFile = testDirectoryUrl.appending(path: "testFile.txt")
        try testContent1.write(toFile: testFile.path, atomically: true, encoding: .utf8)

        let testFileExist1 = fileManager.fileExists(atPath: testFile.path)
        XCTAssertTrue(testFileExist1, "Inproper setup.")

        let testContent2 = UUID().uuidString
        let testMovedFile = testDirectoryUrl.appending(path: "testMovedFile.txt")
        try testContent2.write(toFile: testMovedFile.path, atomically: true, encoding: .utf8)

        let testMoveFileExist1 = fileManager.fileExists(atPath: testMovedFile.path)
        XCTAssertTrue(testMoveFileExist1, "Inproper setup.")

        let readTestContent1 = try String(contentsOf: testMovedFile)
        XCTAssertTrue(testContent2 == readTestContent1, "Failed to read test content.")

        // Test starts.
        try move(from: testFile, to: testMovedFile)

        // Assert file move successful.
        let testFileExist2 = fileManager.fileExists(atPath: testFile.path)
        XCTAssertFalse(testFileExist2, "Failed to move file.")

        // Assert content of destination file is the same as the content written to the source file.
        let readTestContent2 = try String(contentsOf: testMovedFile)
        XCTAssertTrue(testContent1 == readTestContent2, "Failed to read test content.")
    }

    /// Test move file function.
    ///
    /// Test moving file that exist to destination that does not yet exist.
    func testMoveFile() throws {
        let fileManager = FileManager.default

        // Setup test condition.
        let testContent = UUID().uuidString
        let testFile = testDirectoryUrl.appending(path: "testFile.txt")
        let testMovedFile = testDirectoryUrl.appending(path: "testMovedFile.txt")

        try testContent.write(toFile: testFile.path, atomically: true, encoding: .utf8)

        let testFileExist1 = fileManager.fileExists(atPath: testMovedFile.path)
        XCTAssertTrue(testFileExist1, "Inproper setup.")

        let testMoveFileExist1 = fileManager.fileExists(atPath: testMovedFile.path)
        XCTAssertFalse(testMoveFileExist1, "Inproper setup.")

        // Test starts.
       try move(from: testFile, to: testMovedFile)

        // Assert file move successful.
        let testFileExist2 = fileManager.fileExists(atPath: testFile.path)
        XCTAssertFalse(testFileExist2, "Failed to move file.")

        let testMoveFileExist2 = fileManager.fileExists(atPath: testMovedFile.path)
        XCTAssertTrue(testMoveFileExist2, "Failed to move file.")

        // Assert content of destination file is the same as the content written to the source file.
        let readTestContent = try String(contentsOf: testMovedFile)
        XCTAssertTrue(testContent == readTestContent, "Failed to read test content.")
    }

    /// Test move file function.
    ///
    /// Test moving file that does not exist.
    func testMoveNonExistFile() throws {
        let fileManager = FileManager.default

        // Setup test condition.
        let testFile = testDirectoryUrl.appending(path: "testFile.txt")
        let testMovedFile = testDirectoryUrl.appending(path: "testMovedFile.txt")

        let testFileExist1 = fileManager.fileExists(atPath: testFile.path)
        XCTAssertFalse(testFileExist1, "Inproper setup.")
        let testMoveFileExist1 = fileManager.fileExists(atPath: testMovedFile.path)
        XCTAssertFalse(testMoveFileExist1, "Inproper setup.")

        // Test starts.
        var didThrow = false
        do {
            try move(from: testFile, to: testMovedFile)
        } catch let error {
            // Test is expected to throw exception.
            didThrow = true
            print("error: \(error.localizedDescription)")
        }

        XCTAssertTrue(didThrow, "Failed to throw error when moving file that does not exist.")

        // Assert file move successful.
        let testFileExist2 = fileManager.fileExists(atPath: testFile.path)
        XCTAssertFalse(testFileExist2, "File should not exist.")
        let testMoveFileExist2 = fileManager.fileExists(atPath: testMovedFile.path)
        XCTAssertFalse(testMoveFileExist2, "File should not exist.")
    }

    /// Test remove file function.
    ///
    /// Test removing file that exist.
    func testRemoveFile() throws {
        let fileManager = FileManager.default

        // Setup test condition.
        let testContent = UUID().uuidString
        let testFile = testDirectoryUrl.appending(path: "testFile.txt")

        try testContent.write(toFile: testFile.path, atomically: true, encoding: .utf8)
        var isDirectory: ObjCBool = false
        let testFileExist1 = fileManager.fileExists(atPath: testFile.path, isDirectory: &isDirectory)
        XCTAssertTrue(testFileExist1 && isDirectory.boolValue == false, "Test remove file setup failed.")

        // Test starts.
        try remove(url: testFile)

        // Assert file remove is successful.
        isDirectory = false
        let testFileExist2 = fileManager.fileExists(atPath: testFile.path, isDirectory: &isDirectory)
        XCTAssertFalse(testFileExist2 && isDirectory.boolValue, "Failed to remove test file.")
    }

    /// Test remove file function.
    ///
    /// Test removing file that does not exist.
    func testRemoveNonExistFile() throws {
        let fileManager = FileManager.default

        // Setup test condition.
        let testFile = testDirectoryUrl.appending(path: "testFile.txt")

        var isDirectory: ObjCBool = false
        let testFileExist1 = fileManager.fileExists(atPath: testFile.path, isDirectory: &isDirectory)
        XCTAssertFalse(testFileExist1 && isDirectory.boolValue == false, "Test remove file setup failed.")

        // Test starts.
        try remove(url: testFile)

        // Assert file remove is successful.
        isDirectory = false
        let testFileExist2 = fileManager.fileExists(atPath: testFile.path, isDirectory: &isDirectory)
        XCTAssertFalse(testFileExist2 && isDirectory.boolValue, "Failed to remove test file.")
    }
}
