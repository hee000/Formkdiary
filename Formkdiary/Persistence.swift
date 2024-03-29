//
//  Persistence.swift
//  Formkdiary
//
//  Created by cch on 2022/06/23.
//

import CoreData
import CloudKit

let schemaInit = false

final class PersistenceController: ObservableObject {
  static let shared = PersistenceController()
  
  var ckContainer: CKContainer {
    let storeDescription = persistentContainer.persistentStoreDescriptions.first
    guard let identifier = storeDescription?.cloudKitContainerOptions?.containerIdentifier else {
      fatalError("Unable to get container identifier")
    }
    return CKContainer(identifier: identifier)
  }
  
  var context: NSManagedObjectContext {
    persistentContainer.viewContext
  }
  
  var backgroundContext: NSManagedObjectContext{
//    let background = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//    background.persistentStoreCoordinator = self.persistentContainer.persistentStoreCoordinator
//    background.parent = self.context
    let background = self.persistentContainer.newBackgroundContext()
    background.automaticallyMergesChangesFromParent = true
    background.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

    return background
  }
  
  var privatePersistentStore: NSPersistentStore {
    guard let privateStore = _privatePersistentStore else {
      fatalError("Private store is not set")
    }
    return privateStore
  }

  var sharedPersistentStore: NSPersistentStore {
    guard let sharedStore = _sharedPersistentStore else {
      fatalError("Shared store is not set")
    }
    return sharedStore
  }

  lazy var persistentContainer
  : NSPersistentCloudKitContainer = {
    let container = NSPersistentCloudKitContainer(name: "Formkdiary")

    guard let privateStoreDescription = container.persistentStoreDescriptions.first else {
      fatalError("Unable to get persistentStoreDescription")
    }
    let storesURL = privateStoreDescription.url?.deletingLastPathComponent()
    privateStoreDescription.url = storesURL?.appendingPathComponent("private.sqlite")
    let sharedStoreURL = storesURL?.appendingPathComponent("shared.sqlite")
    guard let sharedStoreDescription = privateStoreDescription.copy() as? NSPersistentStoreDescription else {
      fatalError("Copying the private store description returned an unexpected value.")
    }
    sharedStoreDescription.url = sharedStoreURL

    guard let containerIdentifier = privateStoreDescription.cloudKitContainerOptions?.containerIdentifier else {
      fatalError("Unable to get containerIdentifier")
    }
    let sharedStoreOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerIdentifier)
    sharedStoreOptions.databaseScope = .shared
    sharedStoreDescription.cloudKitContainerOptions = sharedStoreOptions
    container.persistentStoreDescriptions.append(sharedStoreDescription)

    container.loadPersistentStores { loadedStoreDescription, error in
      if let error = error as NSError? {
        fatalError("Failed to load persistent stores: \(error)")
      } else if let cloudKitContainerOptions = loadedStoreDescription.cloudKitContainerOptions {
        guard let loadedStoreDescritionURL = loadedStoreDescription.url else {
          return
        }

        if cloudKitContainerOptions.databaseScope == .private {
          let privateStore = container.persistentStoreCoordinator.persistentStore(for: loadedStoreDescritionURL)
          self._privatePersistentStore = privateStore
        } else if cloudKitContainerOptions.databaseScope == .shared {
          let sharedStore = container.persistentStoreCoordinator.persistentStore(for: loadedStoreDescritionURL)
          self._sharedPersistentStore = sharedStore
        }
      }
    }

    //    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    container.viewContext.automaticallyMergesChangesFromParent = true
//
//    do {
//      try container.viewContext.setQueryGenerationFrom(.current)
//    } catch {
//      fatalError("Failed to pin viewContext to the current generation: \(error)")
//    }
    
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
  
  private var _privatePersistentStore: NSPersistentStore?
  private var _sharedPersistentStore: NSPersistentStore?
  private init() {}
}


// MARK: Save or delete from Core Data
extension PersistenceController {
  func save() {
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        print("ViewContext save error: \(error)")
      }
    }
  }

  func delete(_ note: NoteMO) {
    context.perform {
      self.context.delete(note)
      self.save()
    }
  }
}

// MARK: Share a record from Core Data
extension PersistenceController {
  func isShared(object: NSManagedObject) -> Bool {
    isShared(objectID: object.objectID)
  }

  func canEdit(object: NSManagedObject) -> Bool {
    return persistentContainer.canUpdateRecord(forManagedObjectWith: object.objectID)
  }

  func canDelete(object: NSManagedObject) -> Bool {
    return persistentContainer.canDeleteRecord(forManagedObjectWith: object.objectID)
  }

  func isOwner(object: NSManagedObject) -> Bool {
    guard isShared(object: object) else { return false }
    guard let share = try? persistentContainer.fetchShares(matching: [object.objectID])[object.objectID] else {
      print("Get ckshare error")
      return false
    }
    if let currentUser = share.currentUserParticipant, currentUser == share.owner {
      return true
    }
    return false
  }

  func getShare(_ note: NoteMO) -> CKShare? {
    guard isShared(object: note) else { return nil }
    guard let shareDictionary = try? persistentContainer.fetchShares(matching: [note.objectID]),
      let share = shareDictionary[note.objectID] else {
      print("Unable to get CKShare")
      return nil
    }
    share[CKShare.SystemFieldKey.title] = note.title
    return share
  }
  

   func remoteShare(at url: URL) async throws -> CKShare? {
    do {
      let metadata = try await ckContainer.shareMetadata(for: url)
      return metadata.share
    } catch let error as CKError{
      print(error)
      persistentContainer.viewContext.refreshAllObjects()
      return nil
    } catch {
      return nil
    }
  }
  


  private func isShared(objectID: NSManagedObjectID) -> Bool {
    var isShared = false
    if let persistentStore = objectID.persistentStore {
      if persistentStore == sharedPersistentStore {
        isShared = true
      } else {
        let container = persistentContainer
        do {
          let shares = try container.fetchShares(matching: [objectID])
          if shares.first != nil {
            isShared = true
          }
        } catch {
          print("Failed to fetch share for \(objectID): \(error)")
        }
      }
    }
    return isShared
  }
}
