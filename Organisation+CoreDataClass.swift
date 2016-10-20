//
//  Organisation+CoreDataClass.swift
//  insightly
//
//  Created by Ian Kennedy on 12/10/2016.
//  Copyright © 2016 Ian Kennedy. All rights reserved.
//

import Foundation
import CoreData


public class Organisation: NSManagedObject {
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(name: String, address: String, addressByLine: String?, imageUrl: String?, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Organisation", in: context)!
        
        super.init(entity: entity, insertInto: context)
        self.name = name
        self.address = address
        if let addressByLine = addressByLine {
            self.addressByLine = addressByLine
        }
        if let url = imageUrl {
            self.imageUrl = url
        }
        self.geocodeComplete = false
    }
}
