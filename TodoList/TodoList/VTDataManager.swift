//
//  VTDataManager.swift
//  GifGallery
//
//  Created by Vince Tran on 8/1/16.
//  Copyright © 2016 Vince Tran. All rights reserved.
//

import UIKit
import CoreData


class VTDataManager: NSObject {
    class var defaultManager: VTDataManager {
        struct Static {
            static let instance = VTDataManager()
        }
        return Static.instance
    }
    
    class func sqliteFileName() -> String {
        return "GifGallery.sqlite"
    }
    
    
    
    //MARK: - GifModel
    func gifEntityName() -> String {
        return "TodoModel"
    }
    
    func gifModel(withID id:Int) -> TodoModel? {
        //filter
        let predicate = NSPredicate(format: "id == \(id)", argumentArray: nil)
        
        if let fetchedGifs = fetchedModels(withEntityName: gifEntityName(), predicate: predicate, sortDescriptors: nil) {
            return fetchedGifs.last as? TodoModel
        } else {
            return nil
        }
    }
    
    func insertOrUpdateGifModel(withID id:Int?) -> TodoModel {
        
        if let modelID = id, model = self.gifModel(withID: modelID) {
            return model
        }
        
        let gifModel = insertModel(withEntityName: gifEntityName()) as TodoModel
        return gifModel
    }
    
    func deleteGifModel(gifModel model:TodoModel) {
        deleteModel(model)
    }
    
    func deleteGifModel(withID id:Int) {
        //filter
        let predicate = NSPredicate(format: "id == \(id)", argumentArray: nil)
        deleteAllInstances(withEntityName: gifEntityName(), predicate: predicate, sortDescriptors: nil)
    }
    
    func deleteAllGifModels() {
        deleteAllInstances(withEntityName: gifEntityName(), predicate: nil, sortDescriptors: nil)
    }
    
    
    func countGifModels() -> Int {
        return countFetchedModels(withEntityName: gifEntityName(), predicate: nil, sortDescriptors: nil)
    }
    
    //Return all gif model in collection
    func gifModelsCollection() -> [TodoModel]? {
        //filter
        let sortDesciptor = NSSortDescriptor(key: "id", ascending: false)
        return fetchedModels(withEntityName: gifEntityName(), predicate: nil, sortDescriptors: [sortDesciptor])
    }
    
    
    //Return fetched Controller, so that we can observe the changes
    func gifModelsFetchedController(type: ListType) -> NSFetchedResultsController {
        let dateSort = NSSortDescriptor(key: "id", ascending: false)
        //filter
        let predicate = NSPredicate(format: "state == \(type.rawValue)", argumentArray: nil)
        let gifController = fetchedController(withEntityName: gifEntityName(), predicate: predicate, sortDescriptors: [dateSort])
        return gifController
        
    }
    
    //MARK: - Generic
    
    private func deleteModel<T:NSManagedObject>(model:T) {
        managedObjectContext.deleteObject(model)
    }
    
    private func insertModel<T:NSManagedObject>(withEntityName entityName:String) -> T {
        let model = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: managedObjectContext) as! T
        return model
    }
    
    private func deleteAllInstances(withEntityName entityName:String, predicate:NSPredicate? , sortDescriptors:[NSSortDescriptor]?) {
        
        //Save all objects to context, prevent conflicts
        saveContext()
        
        NSFetchedResultsController.deleteCacheWithName(nil)
        
        let fetchRequest = fetchedRequest(withEntityName: entityName, predicate: predicate, sortDescriptors: sortDescriptors)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .ResultTypeObjectIDs
        do {
            try persistentStoreCoordinator.executeRequest(deleteRequest, withContext: managedObjectContext)
        } catch {
            print(error)
        }
        
    }
    
    private func countFetchedModels(withEntityName entityName:String, predicate:NSPredicate? , sortDescriptors:[NSSortDescriptor]?) -> Int {
        let fetchRequest = fetchedRequest(withEntityName: entityName, predicate: predicate, sortDescriptors: sortDescriptors)
        
        var err:NSError?
        let count = managedObjectContext.countForFetchRequest(fetchRequest, error: &err)
        if err == nil {
            return count
        } else {
            print(err)
            return 0
        }
        
    }
    
    private func fetchedModels<T:NSManagedObject>(withEntityName entityName:String, predicate:NSPredicate? , sortDescriptors:[NSSortDescriptor]?) -> [T]? {
        let fetchRequest = fetchedRequest(withEntityName: entityName, predicate: predicate, sortDescriptors: sortDescriptors)
        
        do {
            let fetchedModels = try managedObjectContext.executeFetchRequest(fetchRequest)
            return fetchedModels as? [T]
        } catch {
            
            print(error)
            return nil
        }
    }
    
    private func fetchedController(withEntityName entityName:String, predicate:NSPredicate? , sortDescriptors:[NSSortDescriptor]?) -> NSFetchedResultsController {
        let fetchRequest = fetchedRequest(withEntityName: entityName, predicate: predicate, sortDescriptors: sortDescriptors)
        
        let fetchedController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedController
    }
    
    
    private func fetchedRequest(withEntityName entityName:String, predicate:NSPredicate? , sortDescriptors:[NSSortDescriptor]?) -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.includesSubentities = false
        //filter
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        return fetchRequest
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Core Data stack
    
    class func sqliteFilePath() -> String {
        let filePath = NSHomeDirectory().stringByAppendingString("/Documents/\(VTDataManager.sqliteFileName())")
        return filePath
    }
    
    private lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.vincetran.MoHealth" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("GifGallery", withExtension: "mom")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(VTDataManager.sqliteFileName())
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    private lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    internal func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}



