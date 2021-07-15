//
//  Restaurant+CoreDataClass.swift
//  
//
//  Created by Joey Hwang on 10/7/19.
//
//

import Foundation
import CoreData


public class Restaurant: NSManagedObject {
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        print("Init called!")
    }
}
