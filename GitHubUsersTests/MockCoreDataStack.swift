//
//  MockCoreDataStack.swift
//  GitHubUsersTests
//
//  Created by WeyHan Ng on 24/12/2022.
//

import Foundation
@testable import GitHubUsers
import CoreData

/// Mocks CoreDataStack for testing
class MockCoreDataStack: KodecoCoreDataStack, CoreDataStackProtocol {

    override init(modelName: String) {
        super.init(modelName: modelName)

        // Use in-memory store for testing to reduce test time and to allow easy clearing of the
        // CoreData store at the beginning of each test case.
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.url = URL(fileURLWithPath: "/dev/null")

        let container = NSPersistentContainer(name: modelName)
        container.persistentStoreDescriptions = [persistentStoreDescription]

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        storeContainer = container
    }

}
