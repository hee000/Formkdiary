//
//  DailyMO+CoreDataProperties.swift
//  Formkdiary
//
//  Created by hee on 2022/10/18.
//
//

import Foundation
import CoreData


extension DailyMO {

  @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyMO> {
      return NSFetchRequest<DailyMO>(entityName: "Daily")
  }
  
  @NSManaged public var dailyId: UUID
  @NSManaged public var style: Int32
  @NSManaged public var text: String
  @NSManaged public var date: Date
  @NSManaged public var createdAt: Date
  @NSManaged public var editedAt: Date
  @NSManaged public var images: Data?
  @NSManaged public var page: PageMO?
  @NSManaged public var monthly: MonthlyMO?
  @NSManaged public var weekly: WeeklyMO?
  
  public override func awakeFromInsert() {
      super.awakeFromInsert()
    dailyId = UUID()
    text = ""
    date = Date()
    createdAt = Date()
    editedAt = Date()
  }

}

extension DailyMO : Identifiable {

}
