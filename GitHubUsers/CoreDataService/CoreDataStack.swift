//
//  CoreDataStack.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 24/12/2022.
//

import Foundation
import CoreData

/// Used as the stand-in type to accommodate the slightly different version of CoreDataStack used in XCTest cases.
///
/// Code that use of the CoreDataStack can reference the protocol as the type where it can be the app version or
/// the XCTest version.
protocol CoreDataStackProtocol {
    var mainContext: NSManagedObjectContext { get set }
    var storeContainer: NSPersistentContainer { get set }

    func backgroundContext() -> NSManagedObjectContext
    func saveContext()
    func saveContext(_ context: NSManagedObjectContext)
    func saveDerivedContext(_ context: NSManagedObjectContext)

    func saveContextAndWait()
    func saveContextAndWait(_ context: NSManagedObjectContext)
    func saveDerivedContextAndWait(_ context: NSManagedObjectContext)
}

/// Subclass of Kodeco's version of the CoreDataStack
///
/// Addition added to the Kodeco's CoreDataStack:
/// - Make CoreDataStack a singleton.
/// - Added save context and wait methods for saving context.
///
/// Making CoreDataStack a singleton provides easy access to anywhere in the app. The normal convention is to
/// get the reference to the AppDelegate singleton to access the persistent container object property but for non-UI
/// code getting the AppDelegate requires the source file to import UIKit. Avoiding the import of UIKit in non-UI code
/// like view model is the whole point of MVVM.
///
/// The blocking version of the save context methods is useful when calling the save context methods in a
/// background thread where the next action depends on the save context to complete before proceeding.
/// - Note: Avoid using the blocking version in the main thread so not to cause delays to UI updates.
internal class CoreDataStack: KodecoCoreDataStack, CoreDataStackProtocol {
    static let shared = CoreDataStack(modelName: PersistentStore.modelName)

    private override init(modelName: String) {
        super.init(modelName: modelName)
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
