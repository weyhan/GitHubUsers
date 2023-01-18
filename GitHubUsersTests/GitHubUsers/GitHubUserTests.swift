//
//  GitHubUserTests.swift
//  GitHubUsersTests
//
//  Created by WeyHan Ng on 19/12/2022.
//

import XCTest
@testable import GitHubUsers
import CoreData

final class GitHubUserTests: XCTestCase {

    var coreDataStack: MockCoreDataStack!

    override func setUpWithError() throws {
        // Make a blank persistent store.
        coreDataStack = MockCoreDataStack(modelName: PersistentStore.modelName)
    }

    override func tearDownWithError() throws {
        // Clear persistent store stack.
        coreDataStack = nil
    }

    /// Test decoding json data from the GitHub `users` API.
    ///
    /// Mock data is taken from the response of GitHub's API at:
    ///
    /// [https://api.github.com/users?since=0](https://api.github.com/users?since=0)
    func testDecoderJSON() throws {

        guard let data = loadBundleFile(withFilename: "testDecoderJSON", extension: "json") else {
            XCTFail("Failed to load test data; Decoding JSON test could not proceed.")
            return
        }

        let context = coreDataStack.mainContext

        let jsonService = JSONDecoderService<[GitHubUser]>(context: context, coreDataStack: coreDataStack)
        let decoded = try? jsonService.decode(data: data)

        XCTAssertNotNil(decoded)
        guard let decoded = decoded else {
            return
        }

        // Verify all record are decoded.
        XCTAssertTrue(decoded.count == 30, "Unexpected decoded result")

        // Verify first record decoded.
        XCTAssertTrue(decoded[0].login == "mojombo", "Unexpected decoded result")
        XCTAssertTrue(decoded[0].id == 1, "Unexpected decoded result")
        XCTAssertTrue(decoded[0].nodeId == "MDQ6VXNlcjE=", "Unexpected decoded result")
        XCTAssertTrue(decoded[0].avatarUrl == "https://avatars.githubusercontent.com/u/1?v=4", "Unexpected decoded result")
        XCTAssertTrue(decoded[0].gravatarId == "", "Unexpected decoded result")
        XCTAssertTrue(decoded[0].url == "https://api.github.com/users/mojombo", "Unexpected decoded result")
        XCTAssertTrue(decoded[0].htmlUrl == "https://github.com/mojombo", "Unexpected decoded result")
        XCTAssertTrue(decoded[0].followersUrl == "https://api.github.com/users/mojombo/followers", "Unexpected decoded result")
        XCTAssertTrue(decoded[0].followingUrl == "https://api.github.com/users/mojombo/following{/other_user}", "Unexpected decoded result")
        XCTAssertTrue(decoded[0].gistsUrl == "https://api.github.com/users/mojombo/gists{/gist_id}", "Unexpected decoded result")
        XCTAssertTrue(decoded[0].starredUrl == "https://api.github.com/users/mojombo/starred{/owner}{/repo}", "Unexpected decoded result")
        XCTAssertTrue(decoded[0].subscriptionsUrl == "https://api.github.com/users/mojombo/subscriptions", "Unexpected decoded result")
        XCTAssertTrue(decoded[0].organizationsUrl == "https://api.github.com/users/mojombo/orgs", "Unexpected decoded result")
        XCTAssertTrue(decoded[0].reposUrl == "https://api.github.com/users/mojombo/repos", "Unexpected decoded result")
        XCTAssertTrue(decoded[0].eventsUrl == "https://api.github.com/users/mojombo/events{/privacy}", "Unexpected decoded result")
        XCTAssertTrue(decoded[0].receivedEventsUrl == "https://api.github.com/users/mojombo/received_events", "Unexpected decoded result")
        XCTAssertTrue(decoded[0].type == "User", "Unexpected decoded result")
        XCTAssertTrue(decoded[0].siteAdmin == false, "Unexpected decoded result")


        // Verify last record decoded.
        XCTAssertTrue(decoded[29].login == "bmizerany", "Unexpected decoded result")
        XCTAssertTrue(decoded[29].id == 46, "Unexpected decoded result")
        XCTAssertTrue(decoded[29].nodeId == "MDQ6VXNlcjQ2", "Unexpected decoded result")
        XCTAssertTrue(decoded[29].avatarUrl == "https://avatars.githubusercontent.com/u/46?v=4", "Unexpected decoded result")
        XCTAssertTrue(decoded[29].gravatarId == "", "Unexpected decoded result")
        XCTAssertTrue(decoded[29].url == "https://api.github.com/users/bmizerany", "Unexpected decoded result")
        XCTAssertTrue(decoded[29].htmlUrl == "https://github.com/bmizerany", "Unexpected decoded result")
        XCTAssertTrue(decoded[29].followersUrl == "https://api.github.com/users/bmizerany/followers", "Unexpected decoded result")
        XCTAssertTrue(decoded[29].followingUrl == "https://api.github.com/users/bmizerany/following{/other_user}", "Unexpected decoded result")
        XCTAssertTrue(decoded[29].gistsUrl == "https://api.github.com/users/bmizerany/gists{/gist_id}", "Unexpected decoded result")
        XCTAssertTrue(decoded[29].starredUrl == "https://api.github.com/users/bmizerany/starred{/owner}{/repo}", "Unexpected decoded result")
        XCTAssertTrue(decoded[29].subscriptionsUrl == "https://api.github.com/users/bmizerany/subscriptions", "Unexpected decoded result")
        XCTAssertTrue(decoded[29].organizationsUrl == "https://api.github.com/users/bmizerany/orgs", "Unexpected decoded result")
        XCTAssertTrue(decoded[29].reposUrl == "https://api.github.com/users/bmizerany/repos", "Unexpected decoded result")
        XCTAssertTrue(decoded[29].eventsUrl == "https://api.github.com/users/bmizerany/events{/privacy}", "Unexpected decoded result")
        XCTAssertTrue(decoded[29].receivedEventsUrl == "https://api.github.com/users/bmizerany/received_events", "Unexpected decoded result")
        XCTAssertTrue(decoded[29].type == "User", "Unexpected decoded result")
        XCTAssertTrue(decoded[29].siteAdmin == false, "Unexpected decoded result")
    }

    /// Test saving root context.
    ///
    /// Mock data is taken from the response of GitHub's API at:
    ///
    /// [https://api.github.com/users?since=0](https://api.github.com/users?since=0)
    func testSavingRootContext() throws {

        guard let data = loadBundleFile(withFilename: "first30Users", extension: "json") else {
            XCTFail("Failed to load test data; Decoding JSON test could not proceed.")
            return
        }

        let context = coreDataStack.backgroundContext()

        // Observe for NSManagedObjectContextDidSave notification.
        expectation(forNotification: .NSManagedObjectContextDidSave, object: coreDataStack.mainContext) { _ in
                return true
            }

        let jsonService = JSONDecoderService<[GitHubUser]>(context: context, coreDataStack: coreDataStack)

        // Decode data in the background.
        context.perform {
            let decoded = try? jsonService.decode(data: data)
            XCTAssertNotNil(decoded)

            self.coreDataStack.saveContext(context)
        }

        // Wait for 2 seconds for NSManagedObjectContextDidSave notification.
        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Save did not occur")
        }
    }

    /// Test fetch al GitHubUser
    ///
    /// Mock data is taken from the response of GitHub's API at:
    ///
    /// [https://api.github.com/users?since=0](https://api.github.com/users?since=0)
    func testAllFetchGitHubUser() throws {
        let context = coreDataStack.mainContext
        let entity = NSEntityDescription.entity(forEntityName: PersistentStore.entityName, in: context)!
        let user = GitHubUser(entity: entity, insertInto: context)

        // Insert test data of one user record.
        user.login = "mojombo"
        user.id = 1
        user.nodeId = "MDQ6VXNlcjE="
        user.avatarUrl = "https://avatars.githubusercontent.com/u/1?v=4"
        user.gravatarId = ""
        user.url = "https://api.github.com/users/mojombo"
        user.htmlUrl = "https://github.com/mojombo"
        user.followersUrl = "https://api.github.com/users/mojombo/followers"
        user.followingUrl = "https://api.github.com/users/mojombo/following{/other_user}"
        user.gistsUrl = "https://api.github.com/users/mojombo/gists{/gist_id}"
        user.starredUrl = "https://api.github.com/users/mojombo/starred{/owner}{/repo}"
        user.subscriptionsUrl = "https://api.github.com/users/mojombo/subscriptions"
        user.organizationsUrl = "https://api.github.com/users/mojombo/orgs"
        user.reposUrl = "https://api.github.com/users/mojombo/repos"
        user.eventsUrl = "https://api.github.com/users/mojombo/events{/privacy}"
        user.receivedEventsUrl = "https://api.github.com/users/mojombo/received_events"
        user.type = "User"
        user.siteAdmin = false

        coreDataStack.saveContext(context)

        // Fetch all records from persistent storage.
        let request = GitHubUser.fetchRequest()
        let fetched: [GitHubUser]?
        do {
            fetched = try context.fetch(request)
            XCTAssertNotNil(fetched)

        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
            XCTFail("Exception while fetching GitUserData")
            return
        }

        // Make sure there is one and only one record in the persistent store. Because every
        // XCTest cases must start with an empty persistent store, after inserting one record
        // in the persistent store, there must be one and only one record when fetching all
        // records.
        XCTAssertNotNil(fetched)
        XCTAssertTrue(fetched?.count == 1)

        // Make sure the saved recored and the fetched record matches.
        let fetchedUser = fetched!.first!
        XCTAssertTrue(user.login == fetchedUser.login, "Mismatched data between save and fetch.")
        XCTAssertTrue(user.id == fetchedUser.id, "Mismatched data between save and fetch.")
        XCTAssertTrue(user.nodeId == fetchedUser.nodeId, "Mismatched data between save and fetch.")
        XCTAssertTrue(user.avatarUrl == fetchedUser.avatarUrl, "Mismatched data between save and fetch.")
        XCTAssertTrue(user.gravatarId == fetchedUser.gravatarId, "Mismatched data between save and fetch.")
        XCTAssertTrue(user.url == fetchedUser.url, "Mismatched data between save and fetch.")
        XCTAssertTrue(user.htmlUrl == fetchedUser.htmlUrl, "Mismatched data between save and fetch.")
        XCTAssertTrue(user.followersUrl == fetchedUser.followersUrl, "Mismatched data between save and fetch.")
        XCTAssertTrue(user.followingUrl == fetchedUser.followingUrl, "Mismatched data between save and fetch.")
        XCTAssertTrue(user.gistsUrl == fetchedUser.gistsUrl, "Mismatched data between save and fetch.")
        XCTAssertTrue(user.starredUrl == fetchedUser.starredUrl, "Mismatched data between save and fetch.")
        XCTAssertTrue(user.subscriptionsUrl == fetchedUser.subscriptionsUrl, "Mismatched data between save and fetch.")
        XCTAssertTrue(user.organizationsUrl == fetchedUser.organizationsUrl, "Mismatched data between save and fetch.")
        XCTAssertTrue(user.reposUrl == fetchedUser.reposUrl, "Mismatched data between save and fetch.")
        XCTAssertTrue(user.eventsUrl == fetchedUser.eventsUrl, "Mismatched data between save and fetch.")
        XCTAssertTrue(user.receivedEventsUrl == fetchedUser.receivedEventsUrl, "Mismatched data between save and fetch.")
        XCTAssertTrue(user.type == fetchedUser.type, "Mismatched data between save and fetch.")
        XCTAssertTrue(user.siteAdmin == fetchedUser.siteAdmin, "Mismatched data between save and fetch.")
    }

    /// Test fetch user at row function.
    ///
    /// Mock data is taken from the response of GitHub's API at:
    ///
    /// [https://api.github.com/users?since=0](https://api.github.com/users?since=0)
    func testFetchSingleUserAtRow() throws {
        guard let data = loadBundleFile(withFilename: "first30Users", extension: "json") else {
            XCTFail("Failed to load test data; Decoding JSON test could not proceed.")
            return
        }

        let context = coreDataStack.mainContext

        let jsonService = JSONDecoderService<[GitHubUser]>(context: context, coreDataStack: coreDataStack)
        let decoded = try? jsonService.decode(data: data)

        guard let decoded = decoded else {
            XCTFail("Failed to decode JSON")
            return
        }

        var row = -1
        decoded.forEach {
            row += 1
            $0.intRow = row
        }

        coreDataStack.saveContextAndWait(context)

        guard let user = GitHubUser.fetchUser(atRow: row, context: context) else {
            XCTFail("Failed to fetch user at row \(row)")
            return
        }

        XCTAssertTrue(user.row == row && user.login == "bmizerany", "Fetched user at wrong row")
    }

    /// Test fetch user at non-existence row function.
    ///
    /// Mock data is taken from the response of GitHub's API at:
    ///
    /// [https://api.github.com/users?since=0](https://api.github.com/users?since=0)
    func testFetchSingleUserAtRow_FailCase() throws {
        guard let data = loadBundleFile(withFilename: "first30Users", extension: "json") else {
            XCTFail("Failed to load test data; Decoding JSON test could not proceed.")
            return
        }

        let context = coreDataStack.mainContext

        let jsonService = JSONDecoderService<[GitHubUser]>(context: context, coreDataStack: coreDataStack)
        let decoded = try? jsonService.decode(data: data)

        guard let decoded = decoded else {
            XCTFail("Failed to decode JSON")
            return
        }

        var row = -1
        decoded.forEach {
            row += 1
            $0.intRow = row
        }

        coreDataStack.saveContextAndWait(context)

        row += 1
        let user1 = GitHubUser.fetchUser(atRow: row, context: context)
        XCTAssertNil(user1, "fetch using non-existence row should fail but returned bogus result")

        row += 1
        let user2 = GitHubUser.fetchUser(atRow: row, context: context)
        XCTAssertNil(user2, "fetch using non-existence row should fail but returned bogus result")

        row += 100
        let user3 = GitHubUser.fetchUser(atRow: row, context: context)
        XCTAssertNil(user3, "fetch using non-existence row should fail but returned bogus result")

        row = -1
        let user4 = GitHubUser.fetchUser(atRow: row, context: context)
        XCTAssertNil(user4, "fetch using non-existence row should fail but returned bogus result")

        row -= 1
        let user5 = GitHubUser.fetchUser(atRow: row, context: context)
        XCTAssertNil(user5, "fetch using non-existence row should fail but returned bogus result")

        row -= 100
        let user6 = GitHubUser.fetchUser(atRow: row, context: context)
        XCTAssertNil(user6, "fetch using non-existence row should fail but returned bogus result")
    }

    /// Test fetch user by ID function.
    ///
    /// Mock data is taken from the response of GitHub's API at:
    ///
    /// [https://api.github.com/users?since=0](https://api.github.com/users?since=0)
    func testFetchSingleUserById() throws {
        let context = coreDataStack.mainContext

        guard loadFirst30UserMockData(context: context) == true else {
            XCTFail("Failed to load and decode test data; Test could not proceed.")
            return
        }

        let id = 20
        guard let user = GitHubUser.fetchUser(byId: id, context: context) else {
            XCTFail("Failed to fetch user at with ID \(id)")
            return
        }

        XCTAssertTrue(user.id == id && user.login == "kevinclark", "Fetched user at wrong ID")
    }

    /// Test fetch user by ID function with non-existence ID.
    ///
    /// Mock data is taken from the response of GitHub's API at:
    ///
    /// [https://api.github.com/users?since=0](https://api.github.com/users?since=0)
    func testFetchSingleUserById_FailedCase() throws {
        let context = coreDataStack.mainContext

        guard loadFirst30UserMockData(context: context) == true else {
            XCTFail("Failed to load and decode test data; Test could not proceed.")
            return
        }

        let id = 50
        let user = GitHubUser.fetchUser(byId: id, context: context)
        XCTAssertNil(user, "fetch using non-existence ID should fail but returned bogus result")
    }

    /// Fail case for decoding json data test.
    ///
    /// This test is expected to fail in decoding the mock data because the input json structure is a mismatch with the decode model.
    ///
    /// Mock data is taken from the response of GitHub's API at:
    ///
    /// [https://api.github.com/users/defunkt](https://api.github.com/users/defunkt)
    func testDecoder_FailCase() throws {
        // testDecoder_FailCase.json is not in the GitHubUser data structure.
        guard let data = loadBundleFile(withFilename: "testDecoder_FailCase", extension: "json") else {
            XCTFail("Failed to load test data; Decoding JSON test could not proceed.")
            return
        }

        let context = coreDataStack.mainContext
        let jsonService = JSONDecoderService<[GitHubUser]>(context: context, coreDataStack: coreDataStack)

        let decoded = try? jsonService.decode(data: data)

        XCTAssertNil(decoded, "Decoding with mismatch input and model should produce nil but did not")
    }
}

extension GitHubUserTests {

    /// Test update individual GitHubUser profile.
    ///
    /// Update GitHub user profile cached from GitHub user list API with GitHub user profile from individual user profile API.
    ///
    /// Mock data is taken from the response of GitHub's API at:
    ///
    /// [https://api.github.com/users?since=0](https://api.github.com/users?since=0)
    func testUpdateGitHubUsersWithIndividualProfileJSON() throws {
        // Setup for test.
        // =================================================
        // Load mock data from GitHub user list API.
        guard let data = loadBundleFile(withFilename: "testUpdateGitHubUsersWithIndividualProfileData-1", extension: "json") else {
            XCTFail("Failed to load test data; Decoding JSON test could not proceed.")
            return
        }

        let context = coreDataStack.backgroundContext()

        let jsonService = JSONDecoderService<[GitHubUser]>(context: context, coreDataStack: coreDataStack)
        let decoded = try? jsonService.decode(data: data)

        XCTAssertNotNil(decoded)

        coreDataStack.saveContextAndWait(context)

        let request = GitHubUser.fetchRequest()
        let fetched = try? context.fetch(request)
        XCTAssertNotNil(fetched)

        guard let fetched = fetched else {
            return
        }

        XCTAssertTrue(fetched.count == 1, "Unexpected decoded result")

        // Test update.
        // =================================================
        // Load mock JSON from GitHub single user API.
        guard let data2 = loadBundleFile(withFilename: "testUpdateGitHubUsersWithIndividualProfileData-2", extension: "json") else {
            XCTFail("Failed to load test data; Decoding JSON test could not proceed.")
            return
        }

        let jsonService2 = JSONDecoderService<GitHubUser>(context: context, coreDataStack: coreDataStack)
        let decoded2 = try? jsonService2.decode(data: data2)
        XCTAssertNotNil(decoded2)

        coreDataStack.saveContextAndWait(context)

        // Fetch all records from persistent storage.
        let request2 = GitHubUser.fetchRequest()

        let fetched2: [GitHubUser]?
        do {
            fetched2 = try context.fetch(request2)
            XCTAssertNotNil(fetched2)

        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
            XCTFail("Exception while fetching GitUserData")
            return
        }

        guard let fetched2 = fetched2 else {
            return
        }

        XCTAssertTrue(fetched2.count == 1, "Unexpected decoded result")

        // Test changed data is updated successfully.
        XCTAssertTrue(fetched2[0].login == "mojombo-changed", "Unexpected update result")
    }

    /// Test decode individual GitHubUser profile where `hireable` is not `null`.
    ///
    /// Decode GitHub user profile of user from individual user profile API where `hireable` is not `null`.
    ///
    /// Mock data is taken from the response of GitHub's API at:
    ///
    /// [https://api.github.com/users?since=0](https://api.github.com/users?since=0)
    func testDecodeHireable() throws {
        guard let data = loadBundleFile(withFilename: "testDecodeHireable", extension: "json") else {
            XCTFail("Failed to load test data; Decoding JSON test could not proceed.")
            return
        }

        let context = coreDataStack.backgroundContext()

        let jsonService = JSONDecoderService<GitHubUser>(context: context, coreDataStack: coreDataStack)
        let decoded = try? jsonService.decode(data: data)

        XCTAssertNotNil(decoded)

        coreDataStack.saveContextAndWait(context)

        let request = GitHubUser.fetchRequest()

        let fetched: [GitHubUser]?
        do {
            fetched = try context.fetch(request)
            XCTAssertNotNil(fetched)

        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
            XCTFail("Exception while fetching GitUserData")
            return
        }

        guard let fetched = fetched else {
            return
        }

        XCTAssertTrue(fetched.count == 1, "Unexpected decoded result")
        XCTAssert(fetched[0].hireable?.boolValue == true, "Unexpected decoded result")
    }

    /// Test fetching the ID belonging to the last cached GitHub user.
    ///
    /// Mock data is taken from the response of GitHub's API at:
    ///
    /// [https://api.github.com/users?since=0](https://api.github.com/users?since=0)
    func testLastId() throws {
        // Setup for test.
        // =================================================
        // Load mock data from GitHub user list API.
        guard let data = loadBundleFile(withFilename: "testLastId", extension: "json") else {
            XCTFail("Failed to load test data; Decoding JSON test could not proceed.")
            return
        }

        let context = coreDataStack.mainContext

        let jsonService = JSONDecoderService<[GitHubUser]>(context: context, coreDataStack: coreDataStack)
        let decoded = try? jsonService.decode(data: data)

        XCTAssertNotNil(decoded)

        coreDataStack.saveContextAndWait(context)

        let lastId = GitHubUser.lastId(context: context)
        print("lastId: \(lastId)")
        XCTAssertTrue(lastId == 20, "Failed to get the ID of the last profile.")
    }
}

// MARK: - Mockups
extension GitHubUserTests {

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
