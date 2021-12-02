//
//  CoreDataStack.swift

//

import Foundation
import UIKit
import CoreData

class CoreDataStack: NSObject {

    static let sharedInstance = CoreDataStack()
    private override init() {}

    // MARK: - Core Data stack
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "EnrichSalon")
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

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension CoreDataStack {

    func applicationDocumentsDirectory() {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "Enrich" in the application's documents directory.
        if let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {
            print(url.absoluteString)
        }
    }
}

// Core Data CRUD Operations

/** How to Use
 
 let name = "John Appleseed"
 
 let newContact = addRecord(Contact.self)
 newContact.contactNo = 1
 newContact.contactName = name
 
 let contacts = query(Contact.self, search: NSPredicate(format: "contactName == %@", name))
 for contact in contacts
 {
 print ("Contact name = \(contact.contactName), no = \(contact.contactNo)")
 }
 
 deleteRecords(Contact.self, search: NSPredicate(format: "contactName == %@", name))
 
 recs = recordsInTable(Contact.self)
 print ("Contacts table has \(recs) records")
 
 saveDatabase()
 
 ***/

extension CoreDataStack {

    func addRecord<T: NSManagedObject>(_ type: T.Type) -> T {
        let entityName = T.entityName
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        let record = T(entity: entity!, insertInto: context)
        return record
    }

    func recordsInTable<T: NSManagedObject>(_ type: T.Type) -> Int {
        let recs = allRecords(T.self)
        return recs.count
    }

    func allRecords<T: NSManagedObject>(_ type: T.Type, sort: NSSortDescriptor? = nil) -> [T] {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        let request = T.fetchRequest()
        do {
            let results = try context.fetch(request)
            return results as! [T]
        } catch {
            print("Error with request: \(error)")
            return []
        }
    }

    func query<T: NSManagedObject>(_ type: T.Type, search: NSPredicate?, sort: NSSortDescriptor? = nil, multiSort: [NSSortDescriptor]? = nil) -> [T] {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        let request = T.fetchRequest()
        if let predicate = search {
            request.predicate = predicate
        }
        if let sortDescriptors = multiSort {
            request.sortDescriptors = sortDescriptors
        } else if let sortDescriptor = sort {
            request.sortDescriptors = [sortDescriptor]
        }

        do {
            let results = try context.fetch(request)
            return results as! [T]
        } catch {
            print("Error with request: \(error)")
            return []
        }
    }

    func deleteRecord(_ object: NSManagedObject) {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        context.delete(object)
    }

    func deleteRecords<T: NSManagedObject>(_ type: T.Type, search: NSPredicate? = nil) {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext

        let results = query(T.self, search: search)
        for record in results {
            context.delete(record)
        }
    }

    func saveDatabase() {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext

        do {
            try context.save()
        } catch {
            print("Error saving database: \(error)")
        }
    }

    // MARK: - // updateDataBase
    func updateDataBase(obj: AnyObject) {

//        if obj is HairTreatmentModule.Something.Items {
//
//            let modelObjectItem = obj as? HairTreatmentModule.Something.Items
//            let records = CoreDataStack.sharedInstance.allRecords(SelectedSalonService.self)
//            for (_, element) in records.enumerated() {
//                if(element.selectedItemId == modelObjectItem!.id) {
//                    CoreDataStack.sharedInstance.deleteRecords(SelectedSalonService.self, search: NSPredicate(format: "selectedItemId == \((modelObjectItem?.id)!)" ))
//
//                    CoreDataStack.sharedInstance.saveDatabase()
//                    break
//                }
//            }
//
//            let newRecord = CoreDataStack.sharedInstance.addRecord(SelectedSalonService.self)
//            newRecord.selectedItemId = (modelObjectItem?.id)!
//            newRecord.selectedItemValue = GenericClass.sharedInstance.convertCodableToJSONString(obj: modelObjectItem)
//
//            CoreDataStack.sharedInstance.saveDatabase()
//
//        }

    }
}

/***How to use
 class func create<T: NSManagedObject>() -> T {
 ...
 }
 
 let employee: User = User.create()
 employee.name = "The Dude"
 
 ***/
public extension NSManagedObject {
    class var entityName: String {
        var name = NSStringFromClass(self)
        name = name.components(separatedBy: ".").last!
        return name
    }

//    class func create<T: NSManagedObject>() -> T {
//        guard let entityDescription = NSEntityDescription.entity(forEntityName: T.entityName, in: CoreDataStack.sharedInstance.persistentContainer.viewContext) else { fatalError("Unable to create \(T.entityName) NSEntityDescription") }
//        guard let object = NSManagedObject(entity: entityDescription, insertInto: CoreDataStack.sharedInstance.persistentContainer.viewContext) as? T else { fatalError("Unable to create \(T.entityName) NSManagedObject")}
//        return object
//    }
}
