//
//  TodoModel.swift
//  TodoList
//
//  Created by VuVince on 9/13/16.
//  Copyright © 2016 VuVince. All rights reserved.
//

import Foundation
import CoreData


class TodoModel: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    func reverseState() {
        state = state == 0 ? 1 : 0
    }

}
