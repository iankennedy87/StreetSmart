//
//  Organisation+CoreDataProperties.swift
//  
//
//  Created by Ian Kennedy on 21/10/2016.
//
//

import Foundation
import CoreData

extension Organisation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Organisation> {
        return NSFetchRequest<Organisation>(entityName: "Organisation");
    }

    @NSManaged public var address: String?
    @NSManaged public var addressByLine: String?
    @NSManaged public var geocodeComplete: Bool
    @NSManaged public var geocodeSuccess: Bool
    @NSManaged public var image: NSData?
    @NSManaged public var imageUrl: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var user: User?

}
