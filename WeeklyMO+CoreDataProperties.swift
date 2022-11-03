//
//  WeeklyMO+CoreDataProperties.swift
//  Formkdiary
//
//  Created by cch on 2022/09/15.
//
//

import Foundation
import CoreData


enum weeklyStyle: Int32 {
  case one = 0
  case two = 1
}


extension WeeklyMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeeklyMO> {
        return NSFetchRequest<WeeklyMO>(entityName: "Weekly")
    }

  @NSManaged public var date: Date
  @NSManaged public var style: Int32
  // 0 한줄보기
  // 1 두줄보기
  @NSManaged public var weeklyId: UUID
  @NSManaged public var dailies: NSSet
  @NSManaged public var page: PageMO?

  public override func awakeFromInsert() {
      super.awakeFromInsert()
    weeklyId = UUID()
    date = Date()
    dailies = []
  }

}

// MARK: Generated accessors for dailies
extension WeeklyMO {

    @objc(addDailiesObject:)
    @NSManaged public func addToDailies(_ value: DailyMO)

    @objc(removeDailiesObject:)
    @NSManaged public func removeFromDailies(_ value: DailyMO)

    @objc(addDailies:)
    @NSManaged public func addToDailies(_ values: NSSet)

    @objc(removeDailies:)
    @NSManaged public func removeFromDailies(_ values: NSSet)

}

extension WeeklyMO : Identifiable {

}
