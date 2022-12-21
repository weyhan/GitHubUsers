//
//  CoreDataStack.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 24/12/2022.
//

import Foundation
import CoreData

protocol CoreDataStackProtocol {
    var mainContext: NSManagedObjectContext { get set }
    var storeContainer: NSPersistentContainer { get set }

    func backgroundContext() -> NSManagedObjectContext
    func saveContext()
    func saveContext(_ context: NSManagedObjectContext)
    func saveDerivedContext(_ context: NSManagedObjectContext)
}

internal class CoreDataStack: KodecoCoreDataStack, CoreDataStackProtocol {
    static let shared = CoreDataStack(modelName: PersistentStore.modelName)

    private override init(modelName: String) {
        super.init(modelName: modelName)
    }
}
