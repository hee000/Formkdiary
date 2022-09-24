//
//  PageMO+CoreDataProperties.swift
//  Formkdiary
//
//  Created by cch on 2022/09/22.
//
//

import Foundation
import CoreData


extension PageMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PageMO> {
        return NSFetchRequest<PageMO>(entityName: "Page")
    }
  
  @NSManaged public var pageId: UUID
  @NSManaged public var createdAt: Date
  @NSManaged public var index: Int32
  @NSManaged public var note: NoteMO?
  @NSManaged public var title: String
  @NSManaged public var monthly: MonthlyMO?
  @NSManaged public var weekly: WeeklyMO?
  @NSManaged public var daily: DailyMO?
  @NSManaged public var memo: MemoMO?

  public override func awakeFromInsert() {
      super.awakeFromInsert()
    pageId = UUID()
    createdAt = Date()
    title = ""
  }

}

extension PageMO : Identifiable {

}
