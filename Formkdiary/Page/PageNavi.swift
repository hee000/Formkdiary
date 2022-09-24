//
//  NaviTitle.swift
//  Formkdiary
//
//  Created by cch on 2022/09/22.
//

import Foundation
import CoreData

class PageNavi: ObservableObject {
  @Published var title: String = ""
  @Published var pageObjectID: NSManagedObjectID? = nil
}
