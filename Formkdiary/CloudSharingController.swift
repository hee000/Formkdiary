//
//  CloudSharingController.swift
//  Formkdiary
//
//  Created by hee on 2022/10/19.
//

import CloudKit
import SwiftUI

struct CloudSharingView: UIViewControllerRepresentable {
  let share: CKShare
  let container: CKContainer
  let note: NoteMO

  func makeCoordinator() -> CloudSharingCoordinator {
    CloudSharingCoordinator(note: note)
  }

  func makeUIViewController(context: Context) -> UICloudSharingController {
    share[CKShare.SystemFieldKey.title] = note.title
    share[CKShare.SystemFieldKey.thumbnailImageData] = UIImage(named: "ic_share")!.pngData() as CKRecordValue?
    
    let controller = UICloudSharingController(share: share, container: container)
    controller.modalPresentationStyle = .none
    controller.delegate = context.coordinator
    
    return controller
  }

  func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {
  }
}

final class CloudSharingCoordinator: NSObject, UICloudSharingControllerDelegate {
  let stack = PersistenceController.shared
  let note: NoteMO
  init(note: NoteMO) {
    self.note = note
  }

  func itemTitle(for csc: UICloudSharingController) -> String? {
    note.title
  }
  
  func itemThumbnailData(for csc: UICloudSharingController) -> Data? { //공유시
    let image = UIImage(named: "ic_share")
    return image?.pngData()
  }

  func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
    print("Failed to save share: \(error)")
  }

  func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
    print("Saved the share")
  }

  func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
    if !stack.isOwner(object: note) { // not owner
      stack.delete(note)
    } else {
      let cloneNote = try! MOCloner().clone(object: note) as! NoteMO
      
      guard let rec = stack.persistentContainer.record(for: note.objectID) else {return}
      
      Task {
        do {
          try await performZoneCleanup(recordId: rec.recordID)
        } catch {
          print("*** Error in performZoneCleanup: ", error)
        }

        stack.delete(note)
        CoreDataSave()
      }

    } // else
  }
  
  func performZoneCleanup(recordId: CKRecord.ID) async throws {
    let zoneName = recordId.recordName
    let zoneId = recordId.zoneID

    if zoneName != "com.apple.coredata.cloudkit.zone" {
      let zoneID = try await stack.persistentContainer.purgeObjectsAndRecordsInZone(with: zoneId, in: stack.privatePersistentStore)

      print("ZoneID purged: \(zoneID)")
    }

    print("CoreDataStack has completed empty zone cleanup")
  }
}
