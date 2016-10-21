//
//  User+CoreDataProperties.swift
//  
//
//  Created by Ian Kennedy on 21/10/2016.
//
//

import Foundation
import CoreData

extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User");
    }

    @NSManaged public var apiKey: String?
    @NSManaged public var customersDownloaded: Bool
    @NSManaged public var hasKey: Bool
    @NSManaged public var userId: String?
    @NSManaged public var email: String?
    @NSManaged public var organisations: NSSet?

}

// MARK: Generated accessors for organisations
extension User {

    @objc(addOrganisationsObject:)
    @NSManaged public func addToOrganisations(_ value: Organisation)

    @objc(removeOrganisationsObject:)
    @NSManaged public func removeFromOrganisations(_ value: Organisation)

    @objc(addOrganisations:)
    @NSManaged public func addToOrganisations(_ values: NSSet)

    @objc(removeOrganisations:)
    @NSManaged public func removeFromOrganisations(_ values: NSSet)

}
