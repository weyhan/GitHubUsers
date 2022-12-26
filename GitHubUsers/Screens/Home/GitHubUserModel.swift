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

    // Keep index of UITableView row position.
    @NSManaged var row: Int64

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
    }

    /// Initialize from decoder.
    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else {
            fatalError("Error: Missing managed object context")
        }

        let entity = NSEntityDescription.entity(forEntityName: PersistentStore.entityName, in: context)!

        self.init(entity: entity, insertInto: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)

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

        // Set to defaults value. Actual row value will be assigned after decoding.
        self.row = -1
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
    static func lastId() -> Int {
        let request = GitHubUser.fetchRequest()
        request.predicate = NSPredicate(format: "id == max(id)")

        let result = try? CoreDataStack.shared.mainContext.fetch(request)

        guard let lastId = result?.first?.id else {
            return -1
        }

        return Int(lastId)
    }
}

