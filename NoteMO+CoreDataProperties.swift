//
//  NoteMO+CoreDataProperties.swift
//  Formkdiary
//
//  Created by cch on 2022/09/23.
//
//

import Foundation
import CoreData

enum noteStyle: Int32 {
  case list = 0
  case page = 1
}

extension NoteMO {

  @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteMO> {
      return NSFetchRequest<NoteMO>(entityName: "Note")
  }

  @NSManaged public var noteId: UUID
  @NSManaged public var createdAt: Date
  @NSManaged public var title: String
  @NSManaged public var titleVisible: Bool
  @NSManaged public var column: Int16
  @NSManaged public var lastIndex: Int32
//  @NSManaged public var isGird: Bool
  
  @NSManaged public var style: Int32
  // 0 목록
  // 1 페이지
  
  @NSManaged public var noteIndex: Int32
  @NSManaged public var pages: NSSet

  public override func awakeFromInsert() {
      super.awakeFromInsert()
    noteId = UUID()
    createdAt = Date()
  }
  
  

}

// MARK: Generated accessors for pages
extension NoteMO {

    @objc(addPagesObject:)
    @NSManaged public func addToPages(_ value: PageMO)

    @objc(removePagesObject:)
    @NSManaged public func removeFromPages(_ value: PageMO)

    @objc(addPages:)
    @NSManaged public func addToPages(_ values: NSSet)

    @objc(removePages:)
    @NSManaged public func removeFromPages(_ values: NSSet)

}

extension NoteMO : Identifiable {

}
