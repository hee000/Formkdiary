//
//  MonthlyMO+CoreDataProperties.swift
//  Formkdiary
//
//  Created by cch on 2022/07/01.
//
//

import Foundation
import CoreData


extension MonthlyMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MonthlyMO> {
        return NSFetchRequest<MonthlyMO>(entityName: "Monthly")
    }

    @NSManaged public var date: Date
    @NSManaged public var style: Int32
    @NSManaged public var monthlyId: UUID
    @NSManaged public var dailies: NSSet
    @NSManaged public var page: PageMO?

  public override func awakeFromInsert() {
      super.awakeFromInsert()
    monthlyId = UUID()
    date = Date()
    dailies = []
  }
}

// MARK: Generated accessors for dailies
extension MonthlyMO {

    @objc(addDailiesObject:)
    @NSManaged public func addToDailies(_ value: DailyMO)

    @objc(removeDailiesObject:)
    @NSManaged public func removeFromDailies(_ value: DailyMO)

    @objc(addDailies:)
    @NSManaged public func addToDailies(_ values: NSSet)

    @objc(removeDailies:)
    @NSManaged public func removeFromDailies(_ values: NSSet)

}

extension MonthlyMO : Identifiable {

}
