//
//  User+CoreDataClass.swift
//  
//
//  Created by Ian Kennedy on 21/10/2016.
//
//

import Foundation
import CoreData


public class User: NSManagedObject {
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(userId: String, email: String, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)!
        
        super.init(entity: entity, insertInto: context)
        self.userId = userId
        self.email = email
        self.hasKey = false
        self.customersDownloaded = false
    }
}
