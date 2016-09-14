//
//  ListDataSource.swift
//  TodoList
//
//  Created by VuVince on 9/13/16.
//  Copyright © 2016 VuVince. All rights reserved.
//

import UIKit

import UIKit
import CoreData


protocol ListDataSourceDelegate {
    
}


enum ListType: Int {
    case Pending = 0
    case Done = 1
}

class ListDataSource: NSObject {
    var tableView: UITableView!
    var delegate: ListDataSourceDelegate?
    private let cellID = "Cell"
    var type: ListType!
    private var fetchedController: NSFetchedResultsController!
    
    lazy private var updateStateOperation = [Int: StateOperation]()
    
    init(tableView:UITableView, delegate: ListDataSourceDelegate?, type:ListType = .Pending) {
        super.init()
        
        self.type = type
        self.tableView = tableView
        self.delegate = delegate
        commonSetting()
        
    }
    
    func commonSetting() {
        fetchedController = VTDataManager.defaultManager.todoModelsFetchedController(type)
        
        fetchedController.delegate = self
        do {
            try fetchedController.performFetch()
        } catch {
            
        }
        
        
        tableView.registerNib(UINib.init(nibName: "TodoViewCell", bundle: nil), forCellReuseIdentifier: cellID)
        tableView.delegate = self
        tableView.dataSource = self
    }
       
}


//MARK: - NSFetchedResultsControllerDelegate
extension ListDataSource: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            break
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
            break
        case .Move:
            //I dont use move cells, because cell may not be up to date.
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            break
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            break
            
        }
    }
}


//MARK: - UITableViewDataSource
extension ListDataSource: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (fetchedController.sections?.count)!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedController.sections![section].numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID) as! TodoViewCell
        
        if let model = fetchedController.objectAtIndexPath(indexPath) as? TodoModel {
            cell.label.text = model.name
            
            
            if updateStateOperation[(model.id?.integerValue)!] != nil{
                cell.cancelLabel.hidden = false
            } else {
                cell.cancelLabel.hidden = true
                
            }
        }
        
        return cell
    }
    

}

//MARK: - UITableViewDelegate
extension ListDataSource: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let model = fetchedController.objectAtIndexPath(indexPath) as? TodoModel {
            if let operation = updateStateOperation[(model.id?.integerValue)!] {
                operation.cancel()
                updateStateOperation.removeValueForKey((model.id?.integerValue)!)
            } else {
                let operation = StateOperation(withID: (model.id?.integerValue)!, delegate: self)
                operation.start()
                updateStateOperation[(model.id?.integerValue)!] = operation
                
            }
        }
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let todoModel = fetchedController.objectAtIndexPath(indexPath) as? TodoModel {
                VTDataManager.defaultManager.deletetodoModel(todoModel: todoModel)
            }
        }
    }
}

//MARK: - StateOperationDelegate
extension ListDataSource: StateOperationDelegate {
    func didFinishStateOperation(operation: StateOperation) {
        updateStateOperation.removeValueForKey(operation.id)
    }
}