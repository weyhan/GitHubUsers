//
//  GitHubUserModel.swift
//  GitHubUsers
//
//  Created by WeyHan Ng on 18/12/2022.
//

import Foundation
import CoreData

/// CoreData model for GitHub user list.
@objc(GitHubUser)
class GitHubUser: NSManagedObject, Decodable {

    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<GitHubUser> {
        return NSFetchRequest<GitHubUser>(entityName: PersistentStore.entityName)
    }

    @NSManaged var login: String
    @NSManaged var id: Int64
    @NSManaged var nodeId: String
    @NSManaged var avatarUrl: String
    @NSManaged var gravatarId: String
    @NSManaged var url: String
    @NSManaged var htmlUrl: String
    @NSManaged var followersUrl: String
    @NSManaged var followingUrl: String
    @NSManaged var gistsUrl: String
    @NSManaged var starredUrl: String
    @NSManaged var subscriptionsUrl: String
    @NSManaged var organizationsUrl: String
    @NSManaged var reposUrl: String
    @NSManaged var eventsUrl: String
    @NSManaged var receivedEventsUrl: String
    @NSManaged var type: String
    @NSManaged var siteAdmin: Bool
    @NSManaged var name: String?
    @NSManaged var company: String?
    @NSManaged var blog: String?
    @NSManaged var location: String?
    @NSManaged var email: String?
    @NSManaged var hireable: NSNumber?
    @NSManaged var bio: String?
    @NSManaged var twitterUsername: String?
    @NSManaged var publicRepos: NSDecimalNumber?
    @NSManaged var publicGists: NSDecimalNumber?
    @NSManaged var followers: NSDecimalNumber?
    @NSManaged var following: NSDecimalNumber?
    @NSManaged var createdAt: String?
    @NSManaged var updatedAt: String?

    // Relationship with Notes entity
    @NSManaged public var notes: Notes?

    // Keep index of UITableView row position.
    @NSManaged var row: Int64

    // Keep the date of the last time the user profile is viewed.
    @NSManaged var lastViewed: Date?

    enum CodingKeys: CodingKey {
        case login
        case id
        case nodeId
        case avatarUrl
        case gravatarId
        case url
        case htmlUrl
        case followersUrl
        case followingUrl
        case gistsUrl
        case starredUrl
        case subscriptionsUrl
        case organizationsUrl
        case reposUrl
        case eventsUrl
        case receivedEventsUrl
        case type
        case siteAdmin
        case name
        case company
        case blog
        case location
        case email
        case hireable
        case bio
        case twitterUsername
        case publicRepos
        case publicGists
        case followers
        case following
        case createdAt
        case updatedAt
    }

    /// Initialize from decoder.
    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else {
            fatalError("Error: Missing managed object context")
        }

        let entity = NSEntityDescription.entity(forEntityName: PersistentStore.entityName, in: context)!

        self.init(entity: entity, insertInto: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Data from GitHub user list endpoint. i.e. https://api.github.com/users?since=[id]
        self.login = try container.decode(String.self, forKey: .login)
        self.id = try container.decode(Int64.self, forKey: .id)
        self.nodeId = try container.decode(String.self, forKey: .nodeId)
        self.avatarUrl = try container.decode(String.self, forKey: .avatarUrl)
        self.gravatarId = try container.decode(String.self, forKey: .gravatarId)
        self.url = try container.decode(String.self, forKey: .url)
        self.htmlUrl = try container.decode(String.self, forKey: .htmlUrl)
        self.followersUrl = try container.decode(String.self, forKey: .followersUrl)
        self.followingUrl = try container.decode(String.self, forKey: .followingUrl)
        self.gistsUrl = try container.decode(String.self, forKey: .gistsUrl)
        self.starredUrl = try container.decode(String.self, forKey: .starredUrl)
        self.subscriptionsUrl = try container.decode(String.self, forKey: .subscriptionsUrl)
        self.organizationsUrl = try container.decode(String.self, forKey: .organizationsUrl)
        self.reposUrl = try container.decode(String.self, forKey: .reposUrl)
        self.eventsUrl = try container.decode(String.self, forKey: .eventsUrl)
        self.receivedEventsUrl = try container.decode(String.self, forKey: .receivedEventsUrl)
        self.type = try container.decode(String.self, forKey: .type)
        self.siteAdmin = try container.decode(Bool.self, forKey: .siteAdmin)

        // Additional data from hitting the GitHub user's individual endpoint not available
        // when hitting the GitHub user list endpoint. i.e. https://api.github.com/users/[username]
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.company = try container.decodeIfPresent(String.self, forKey: .company)
        self.blog = try container.decodeIfPresent(String.self, forKey: .blog)
        self.location = try container.decodeIfPresent(String.self, forKey: .location)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.hireable = try container.decodeIfPresent(Bool.self, forKey: .hireable) as? NSNumber
        self.bio = try container.decodeIfPresent(String.self, forKey: .bio)
        self.twitterUsername = try container.decodeIfPresent(String.self, forKey: .twitterUsername)
        self.publicRepos = try container.decodeIfPresent(Decimal.self, forKey: .publicRepos) as NSDecimalNumber?
        self.publicGists = try container.decodeIfPresent(Decimal.self, forKey: .publicGists) as NSDecimalNumber?
        self.followers = try container.decodeIfPresent(Decimal.self, forKey: .followers) as NSDecimalNumber?
        self.following = try container.decodeIfPresent(Decimal.self, forKey: .following) as NSDecimalNumber?
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)

        // Set to defaults value. Actual row value will be assigned after decoding.
        self.row = -1

        // Defaults to never viewed before.
        self.lastViewed = nil
    }
}

extension GitHubUser: Identifiable { }

extension GitHubUser {

    /// Retrieve the total number of cached GitHub users records.
    static func count() -> Int {
        let context = CoreDataStack.shared.mainContext

        let fetchRequest = GitHubUser.fetchRequest()
        fetchRequest.includesPropertyValues = false
        fetchRequest.includesSubentities = false
        let count = try? context.count(for: fetchRequest)

        return count ?? 0
    }

    /// Retrieve the ID of the last GitHub user cached.
    ///
    /// - Parameters:
    ///   - context: Managed object context. Defaults to main context.
    static func lastId(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) -> Int {
        let request = GitHubUser.fetchRequest()
        request.predicate = NSPredicate(format: "id == max(id)")
        let result = try? context.fetch(request)

        guard let lastId = result?.first?.id else {
            return -1
        }

        return Int(lastId)
    }

    /// Retrieve user profile from cache at certain row.
    ///
    /// If the user profile is available in cached the `GitHubUser` object is returned. Otherwise nil is returned.
    /// - Parameters:
    ///   - atRow: The user profile row number.
    ///   - context: Managed object context. Defaults to main context.
    /// - Returns: The user profile type `GitHubUser` that contains the user profile data or nil.
    static func fetchUser(atRow row: Int, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) -> GitHubUser? {

        let fetchRequest = GitHubUser.fetchRequest()
        let predicate = NSPredicate(format: "row == %i", row)

        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1

        guard let user = try? context.fetch(fetchRequest).first else {
            return nil
        }

        return user

    }

    /// Retrieve user profile from cache by ID.
    ///
    /// If the user profile is available in cached the `GitHubUser` object is returned. Otherwise nil is returned.
    /// - Parameters:
    ///   - withId: Users GitHub ID.
    ///   - context: Managed object context. Defaults to main context.
    /// - Returns: The user profile type `GitHubUser` that contains the user profile data or nil.
    static func fetchUser(byId id: Int, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) -> GitHubUser? {

        let fetchRequest = GitHubUser.fetchRequest()
        let predicate = NSPredicate(format: "id == %i", id)

        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1

        guard let user = try? context.fetch(fetchRequest).first else {
            return nil
        }

        return user

    }

    /// Retrieve profile notes from cache by ID.
    ///
    /// If the profile notes is available in cached the `Notes` object is returned. Otherwise nil is returned.
    /// - Parameters:
    ///   - withId: Users GitHub ID.
    ///   - context: Managed object context. Defaults to main context.
    /// - Returns: The profile note type `Notes` that contains the profile notes or nil.
    static func fetchNotes(byId id: Int, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) -> Notes? {

        let fetchRequest = Notes.fetchRequest()
        let predicate = NSPredicate(format: "profile.id == %i", id)

        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1

        let notes = try? context.fetch(fetchRequest).first
        guard let notes = notes else {
            return nil
        }

        return notes
    }

    /// Retrieve user profile from cache search by compound predicates.
    ///
    /// - Parameters:
    ///   - predicates: A`NSPredicate` object use in the fetch request to find user profiles.
    ///   - context: Managed object context. Defaults to main context.
    /// - Returns: An array of `GitHubUser` or nil if none is found.
    static func fetchUsers(predicates: NSPredicate, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) -> [GitHubUser]? {
        let request = GitHubUser.fetchRequest()
        request.predicate = predicates

        return try? context.fetch(request)
    }
}

extension GitHubUser {

    /// Saves profile notes to cache.
    ///
    /// The save notes convenience method is non blocking. The completion closure is where any cleanups or next action trigger be placed to ensure
    /// any they executes after the save operation has completed.
    ///
    /// - Note: If the corresponding user is not found, the save operation will bail without triggering the completion closure.
    /// - Parameters:
    ///   - notes: The note text to save.
    ///   - forId: Users GitHub ID.
    ///   - coreDataStack: The CoreDataStack object.
    ///   - context: Managed object context. Defaults to background context.
    ///   - completion: A closure that takes no parameter and returns `Void`.
    static func save(notes text: String,
                     forId id: Int,
                     coreDataStack: CoreDataStackProtocol = CoreDataStack.shared,
                     context: NSManagedObjectContext = CoreDataStack.shared.backgroundContext(),
                     completion: (()->())? = nil) {

        context.perform {
            guard let user = GitHubUser.fetchUser(byId: id, context: context) else {
                completion?()
                return
            }

            if user.notes?.text == nil {
                let notes = Notes(context: context)
                notes.text = text
                user.notes = notes

            } else {
                user.notes?.text = text
            }

            coreDataStack.saveContextAndWait(context)
            completion?()
        }

    }

    /// Remove profile notes on cache.
    ///
    /// The remove notes convenience method is non blocking. The completion closure is where any cleanups or next action trigger be placed to
    /// ensure any they executes after the remove operation has completed.
    ///
    /// - Note: If the corresponding user is not found or the user have no stored notes, the remove operation will bail without triggering the
    /// completion closure.
    /// - Parameters:
    ///   - notesForId: The GitHub user ID to remove notes from.
    ///   - coreDataStack: The CoreData stack. Defaults to global singleton instance.
    ///   - context: Managed object context. Defaults to background context.
    ///   - completion: A closure that takes no parameter and returns `Void`.
    static func remove(notesForId id: Int,
                       coreDataStack: CoreDataStack = CoreDataStack.shared,
                       context: NSManagedObjectContext = CoreDataStack.shared.backgroundContext(),
                       completion: (()->())? = nil) {

        context.perform {
            guard let notes = GitHubUser.fetchNotes(byId: id, context: context) else {
                completion?()
                return
            }

            context.delete(notes)
            coreDataStack.saveContextAndWait(context)
            completion?()
        }

    }
}
