//
//  NotesModel.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 08/01/2023.
//
//

import Foundation
import CoreData

/// CoreData model for profile notes.
@objc(Notes)
class Notes: NSManagedObject {

    @nonobjc class func fetchRequest() -> NSFetchRequest<Notes> {
        return NSFetchRequest<Notes>(entityName: "Notes")
    }

    @NSManaged var text: String?

    // Relationship with GitHubUser entity.
    @NSManaged var profile: GitHubUser?
    
}

extension Notes : Identifiable { }
