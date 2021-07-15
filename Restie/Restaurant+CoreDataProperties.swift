//
//  Restaurant+CoreDataProperties.swift
//  
//
//  Created by Joey Hwang on 10/7/19.
//
//

import Foundation
import CoreData


extension Restaurant {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Restaurant> {
        return NSFetchRequest<Restaurant>(entityName: "Restaurant")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: String?
    @NSManaged public var name: String?

}
