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

    /// Initializes in-memory persistent store.
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

    /// Save main context
    ///
    /// This methods is blocking.
    public func saveContextAndWait() {
        saveContextAndWait(mainContext)
    }

    /// Save given context.
    ///
    /// If context is derived context, also save main context after saving derived context. This methods
    /// is blocking.
    /// - Parameters:
    ///   - context: The context use to save.
    public func saveContextAndWait(_ context: NSManagedObjectContext) {
        if context != mainContext {
            saveDerivedContextAndWait(context)
            return
        }

        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        context.performAndWait {
            do {
                try context.save()

            } catch let error as NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    /// Save given derived context.
    ///
    /// Save derived context followed by saving main context. This methods is blocking.
    /// - Parameters:
    ///   - context: The context use to save.
    public func saveDerivedContextAndWait(_ context: NSManagedObjectContext) {
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        context.performAndWait {
            do {
                try context.save()

            } catch let error as NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }

            self.saveContextAndWait(self.mainContext)
        }
    }

}
