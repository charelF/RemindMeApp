//
//  Persistence.swift
//  RemindMe
//
//  Created by Charel Felten on 30/06/2021.
//

import CoreData
import WidgetKit

struct PersistenceController {
    
    // singleton pattern
    // more info: https://stackoverflow.com/questions/61571960/accessing-core-data-stack-in-mvvm-application/61572075#61572075
    static let shared = PersistenceController()
    
    // these are static so we always use the same
    static let appGroupName = "group.charelfelten.RemindMe"
    static let SQLiteStoreAppendix = "RemindMe.sqlite"
    static let containerURL: URL = {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: PersistenceController.appGroupName)!
    }()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<10 {
            let note = Note(context: viewContext, content: "test")
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        
        container = NSPersistentCloudKitContainer(name: "RemindMe")
        
        let storeURL = PersistenceController.containerURL.appendingPathComponent(PersistenceController.SQLiteStoreAppendix)
        let description = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [description]
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
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
    }
    
    // up until here, everyhting was given by CoreData sample project template
    // now come my own functions
    
    func save() {
        do {
            try self.container.viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
}
