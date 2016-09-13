//
//  TodoModel+CoreDataProperties.swift
//  TodoList
//
//  Created by VuVince on 9/13/16.
//  Copyright © 2016 VuVince. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TodoModel {

    @NSManaged var id: NSNumber?
    @NSManaged var state: NSNumber?
    @NSManaged var name: String?

}
