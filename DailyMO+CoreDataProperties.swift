//
//  DailyMO+CoreDataProperties.swift
//  Formkdiary
//
//  Created by cch on 2022/09/15.
//
//

import Foundation
import CoreData


extension DailyMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyMO> {
        return NSFetchRequest<DailyMO>(entityName: "Daily")
    }

  @NSManaged public var dailyId: UUID
  @NSManaged public var layout: String?
  @NSManaged public var text: String
  @NSManaged public var date: Date
  @NSManaged public var page: PageMO?
  @NSManaged public var monthly: MonthlyMO?
  @NSManaged public var weekly: WeeklyMO?

public override func awakeFromInsert() {
    super.awakeFromInsert()
  dailyId = UUID()
  text = ""
  date = Date()
}

}

extension DailyMO : Identifiable {

}
