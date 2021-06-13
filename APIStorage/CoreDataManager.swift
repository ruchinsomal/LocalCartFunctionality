//
//  CoreDataManager.swift
//  APIStorage
//
//  Created by Ruchin Somal on 2021-06-13.
//

import UIKit
import CoreData

enum EntityName: String {
    case medicines = "Medicines"
}

class CoreDataManager: NSObject {
    
    static let shared = CoreDataManager()
    private override init() {}
    
    // MARK: - FetchRequest
    private func getRequestForEntityName(entity: EntityName) -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: entity.rawValue, in: CoreDataManager.shared.managedObjectContext)
        request.entity = entity
        return request
    }
    
    func get(entity: EntityName) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: entity.rawValue, in: CoreDataManager.shared.managedObjectContext)
    }
    
    // MARK: - Other Operations
    func getObjectFor(entity: EntityName, predicate: NSPredicate) -> [Any] {
        let request = CoreDataManager.shared.getRequestForEntityName(entity: entity)
        request.predicate = predicate
        do {
            let results = try CoreDataManager.shared.managedObjectContext.fetch(request)
            let detail = results
            return detail
        } catch let error {
            print("Operation error: \(error)")
            return []
        }
    }
    
    func getAllObject(entity: EntityName) -> [Any] {
        let request = CoreDataManager.shared.getRequestForEntityName(entity: entity)
        do {
            let results = try CoreDataManager.shared.managedObjectContext.fetch(request)
            let detail = results
            return detail
        } catch let error {
            print("Operation error: \(error)")
            return []
        }
    }
    
    func getAllObjectWithPagination(entity: EntityName, startIndex: Int, endIndex: Int) -> [Any] {
        let request = CoreDataManager.shared.getRequestForEntityName(entity: entity)
        request.fetchOffset = startIndex
        request.fetchLimit = endIndex
        do {
            let results = try CoreDataManager.shared.managedObjectContext.fetch(request)
            let detail = results
            return detail
        } catch let error {
            print("Operation error: \(error)")
            return []
        }
    }
    
    func truncateEntity(entity: EntityName) {
        let request = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: entity.rawValue, in: self.managedObjectContext)
        request.entity = entity
        do {
            let items = try managedObjectContext.fetch(request)
            for item in items {
                if let itemObj = item as? NSManagedObject {
                    managedObjectContext.delete(itemObj)
                }
            }
        } catch let error {
            print("Operation error: \(error)")
        }
    }
    
    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: URL? = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.last
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "APIStorage", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory?.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options:
                [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        if #available(iOS 10.0, *) {
            if #available(iOS 14.0, *) {
                var appDelegate = AppDelegate()
                DispatchQueue.main.async {
                    appDelegate = (UIApplication.shared.delegate as? AppDelegate ?? AppDelegate())
                }
                return appDelegate.persistentContainer.viewContext
            }
            return self.persistentContainer.viewContext
        } else {
            let coordinator = self.persistentStoreCoordinator
            var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            managedObjectContext.parent = self.privateManagedObjectContext
            return managedObjectContext
        }
    }()
    
    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    func saveContext() {
        guard managedObjectContext.hasChanges || privateManagedObjectContext.hasChanges else {
            return
        }
        managedObjectContext.performAndWait {
            do {
                try self.managedObjectContext.save()
            } catch {
                fatalError("Error \(error)")
            }
        }
        privateManagedObjectContext.perform {
            do {
                try self.privateManagedObjectContext.save()
            } catch {
                fatalError("Error \(error)")
            }
        }
    }
    
    // MARK: iOS 10 stack
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "APIStorage")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}
