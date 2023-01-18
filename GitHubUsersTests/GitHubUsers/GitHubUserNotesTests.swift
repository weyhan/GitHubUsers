//
//  GitHubUserNotesTests.swift
//  GitHubUsersTests
//
//  Created by WeyHan Ng on 18/01/2023.
//

import XCTest
@testable import GitHubUsers
import CoreData

final class GitHubUserNotesTests: XCTestCase {

    var coreDataStack: MockCoreDataStack!

    override func setUpWithError() throws {
        // Make a blank persistent store.
        coreDataStack = MockCoreDataStack(modelName: PersistentStore.modelName)
    }

    override func tearDownWithError() throws {
        // Clear persistent store stack.
        coreDataStack = nil
    }

    /// Test save and fetch notes.
    ///
    /// Mock data is taken from the response of GitHub's API at:
    ///
    /// [https://api.github.com/users?since=0](https://api.github.com/users?since=0)
    func testSaveaAndFetchNotes() {
        let id = 3
        let context = coreDataStack.mainContext

        guard loadFirst30UserMockData(context: context) == true else {
            XCTFail("Failed to load and decode test data; Test could not proceed.")
            return
        }

        let sourceNoteText = "Lorem ipsum dolor sit amet."

        GitHubUser.save(notes: sourceNoteText, forId: id, coreDataStack: coreDataStack, context: context) {
            guard let fetchedNotes = GitHubUser.fetchNotes(byId: id, context: context) else {
                XCTFail("Failed to fetch saved notes.")
                return
            }

            XCTAssertTrue(sourceNoteText == fetchedNotes.text, "Fetched note is not the same as original notes.")
        }
    }

    /// Test fetch non-existence notes.
    ///
    /// This test is expected to fail in fetching non-existence note.
    ///
    /// Mock data is taken from the response of GitHub's API at:
    ///
    /// [https://api.github.com/users?since=0](https://api.github.com/users?since=0)
    func testFetchNotes_FailCase() {
        let id = 2
        let context = coreDataStack.mainContext

        guard loadFirst30UserMockData(context: context) == true else {
            XCTFail("Failed to load and decode test data; Test could not proceed.")
            return
        }

        XCTAssertNil(GitHubUser.fetchNotes(byId: id, context: context), "Expecting nil but got bogus notes.")
    }

    /// Test save and remove notes.
    ///
    /// Mock data is taken from the response of GitHub's API at:
    ///
    /// [https://api.github.com/users?since=0](https://api.github.com/users?since=0)
    func testSaveAndRemoveNotes() throws {
        let id = 17
        let context = coreDataStack.mainContext

        guard loadFirst30UserMockData(context: context) == true else {
            XCTFail("Failed to load and decode test data; Test could not proceed.")
            return
        }

        let sourceNoteText = "Lorem ipsum dolor sit amet."

        GitHubUser.save(notes: sourceNoteText, forId: id, coreDataStack: coreDataStack, context: context) {
            guard let fetchedNotes = GitHubUser.fetchNotes(byId: id, context: context) else {
                XCTFail("Failed to fetch saved notes.")
                return
            }

            XCTAssertTrue(sourceNoteText == fetchedNotes.text, "Fetched note is not the same as original notes.")


            GitHubUser.remove(notesForId: id) {
                XCTAssertNil(GitHubUser.fetchNotes(byId: id, context: context), "Expecting nil but got bogus notes.")
            }
        }
    }

}

// MARK: - Mockups
extension GitHubUserNotesTests {

    /// Load file from test bundle of a specific name and extension.
    ///
    /// Locate file given the filename and extension from the test bundle and load into a Data container.
    /// - Parameters:
    ///   - withFilename: Filename of the desired file.
    ///   - extension: File extension of the desired file.
    func loadBundleFile(withFilename filename: String, extension ext: String) -> Data? {
        let testBundle = Bundle(for: type(of: self))
        guard let url = testBundle.url(forResource: filename, withExtension: ext) else {
            return nil
        }

        return try? Data(contentsOf: url)
    }

    func loadFirst30UserMockData(context: NSManagedObjectContext) -> Bool {
        guard let data = loadBundleFile(withFilename: "first30Users", extension: "json") else {
            return false
        }

        let jsonService = JSONDecoderService<[GitHubUser]>(context: context, coreDataStack: coreDataStack)
        let decoded = try? jsonService.decode(data: data)

        guard decoded != nil else { return false }
        coreDataStack.saveContextAndWait(context)

        return true
    }
}
