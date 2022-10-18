//
//  Calendar.swift
//  Formkdiary
//
//  Created by hee on 2022/10/18.
//

import Foundation

class CalendarModel: ObservableObject {
  static let shared = CalendarModel()
  var calendar: Calendar
  
  init() {
    calendar =  Calendar(identifier: .gregorian)
    
    refeshCalFistWeekday()
  }
  
  func refeshCalFistWeekday() {
    if UserDefaults.standard.bool(forKey: "StartMonday") {
      calendar.firstWeekday = 2
    } else {
      calendar.firstWeekday = 1
    }
  }
}
