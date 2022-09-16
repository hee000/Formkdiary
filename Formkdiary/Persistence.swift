//
//  Persistence.swift
//  Formkdiary
//
//  Created by cch on 2022/06/23.
//

import CoreData

let schemaInit = false

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer = {
      let container = NSPersistentCloudKitContainer(name: "Formkdiary")
      

      let storeDirectory = NSPersistentContainer.defaultDirectoryURL()

      let localStoreLocation = storeDirectory.appendingPathComponent("Local.store")
      let localStoreDescription =
          NSPersistentStoreDescription(url: localStoreLocation)
      localStoreDescription.configuration = "Local"

      let cloudStoreLocation = storeDirectory.appendingPathComponent("Cloud.store")
      let cloudStoreDescription =
          NSPersistentStoreDescription(url: cloudStoreLocation)
      cloudStoreDescription.configuration = "Cloud"

      // Set the container options on the cloud store
      cloudStoreDescription.cloudKitContainerOptions =
          NSPersistentCloudKitContainerOptions(
              containerIdentifier: "iCloud.com.cch.Formkdiary")
          
      // Update the container's list of store descriptions
      container.persistentStoreDescriptions = [
          cloudStoreDescription,
          localStoreDescription
      ]
      
      // Load both stores
      container.loadPersistentStores { storeDescription, error in
          guard error == nil else {
              fatalError("Could not load persistent stores. \(error!)")
          }
      }
      
      container.viewContext.automaticallyMergesChangesFromParent = true
      
      if schemaInit {
        do {
            // Use the container to initialize the development schema.
            try container.initializeCloudKitSchema(options: [])
        } catch {
            // Handle any errors.
          print(error)
        }
      }
      
      return container
  }()
  
//    init(inMemory: Bool = false) {
//        container = NSPersistentCloudKitContainer(name: "Formkdiary")
//        if inMemory {
//            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
//        }
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        container.viewContext.automaticallyMergesChangesFromParent = true
//    }
}
