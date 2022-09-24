//
//  MemoMO+CoreDataProperties.swift
//  Formkdiary
//
//  Created by cch on 2022/06/23.
//
//

import Foundation
import CoreData


extension MemoMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MemoMO> {
        return NSFetchRequest<MemoMO>(entityName: "Memo")
    }

    @NSManaged public var memoId: UUID
    @NSManaged public var text: String
    @NSManaged public var page: PageMO?

  public override func awakeFromInsert() {
      super.awakeFromInsert()
    memoId = UUID()
    text = ""
  }
}

extension MemoMO : Identifiable {

}
