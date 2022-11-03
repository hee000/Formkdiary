//
//  PageAddModel.swift
//  Formkdiary
//
//  Created by hee on 2022/11/02.
//

import Foundation
import SwiftUI


enum PageType {
  case monthly
  case weekly
  case daily
  case memo
}



class PageAddModel: ObservableObject {
  @Published var category: [Double] = [1,0,0,0]
  
  @Published var selectedYear : Date
  @Published var selectedMonth : Date
  @Published var selectedWeekDate : Date? = nil
  @Published var selectedDate : Date? = nil
  
  @Published var weekStyle: Int32 = 0
  @Published var memoNameString = ""

  let years : [Date]
  let months : [Date]
  let stack = PersistenceController.shared
  let calendar = CalendarModel.shared.calendar
  
  var pageAddViewExit: () -> Void = { return }
  
  init(){
    self.years = yearArray()
    self.months = monthArray()
    
    self.selectedYear = years[10]
    self.selectedMonth = months[(Calendar.current.component(.month, from: Date()) - 1)]
  }
  
  func setCategory(_ index: Int) {
    var arr = Array(repeating: 0.0, count: 3)
    arr.insert(1.0, at: index)
    category = arr
    print(category)
  }

  @ViewBuilder
  func yearPicker(year: Binding<Date>, fontsize: Int) -> some View {
    Picker(selection: year, label: Text("")) {
      ForEach(years, id:\.self) { year in
        Text(year.toString(dateFormat: "yyyy"))
          .font(.system(size: CGFloat(fontsize), weight: .bold))
      }
    }
    .pickerStyle(WheelPickerStyle())
  }
  
  @ViewBuilder
  func monthPicker(month: Binding<Date>, fontsize: Int) -> some View {
    Picker(selection: month, label: Text("")) {
      ForEach(months, id:\.self) { month in
        Text(month.toString(dateFormat: "MM"))
          .font(.system(size: CGFloat(fontsize), weight: .bold))
      }
    }
    .pickerStyle(WheelPickerStyle())
  }
  
  func getDate() -> Date {
    var dateComponent = DateComponents()
    dateComponent.year = calendar.component(.year, from: selectedYear)
    dateComponent.month = calendar.component(.month, from: selectedMonth)
    guard let date = calendar.date(from: dateComponent) else { return Date() }
    return date
  }
  
  func savePage(note: NoteMO) {
    guard let index = category.firstIndex(of: 1) else { return }
    switch index {
    case 0:
      let newPage = PageMO(context: stack.context)
      let newMonthly = MonthlyMO(context: stack.context)
      
      newMonthly.date = getDate()
      
      
      newPage.monthly = newMonthly
      newPage.index = Int32(note.pages.count)
      //                print("count", note.pages.count)
      newPage.title = createTitle(type: .monthly, date: newMonthly.date)
      
      note.addToPages(newPage)
      note.lastIndex = Int32(note.pages.count - 1)
      
      CoreDataSave()
      pageAddViewExit()
    case 1:
      guard let date = selectedWeekDate else { return }
      let newPage = PageMO(context: stack.context)
      let newWeekly = WeeklyMO(context: stack.context)
      
      newWeekly.date = date
      newWeekly.style = weekStyle
      
      newPage.weekly = newWeekly
      newPage.index = Int32(note.pages.count)
      newPage.title = createTitle(type: .weekly, date: newWeekly.date)
      
      note.addToPages(newPage)
      
      CoreDataSave()
      pageAddViewExit()
    case 2:
      guard let date = selectedDate else { return }
      let newPage = PageMO(context: stack.context)
      let newDaily = DailyMO(context: stack.context)

      newDaily.date = date

      newPage.daily = newDaily
      newPage.index = Int32(note.pages.count)
      newPage.title = createTitle(type: .daily, date: newDaily.date)

      note.addToPages(newPage)

      CoreDataSave()
      pageAddViewExit()
    case 3:
      if memoNameString == "" {
        memoNameString = "제목없음"
      }

      let newPage = PageMO(context: stack.context)
      let newMemo = MemoMO(context: stack.context)

      newPage.memo = newMemo
      newPage.index = Int32(note.pages.count)
      newPage.title = memoNameString

      note.addToPages(newPage)

      CoreDataSave()
      pageAddViewExit()
    default:
      return
    }
  }
  
  
  func createTitle(type: PageType, date: Date) -> String {
    var calendar = Calendar(identifier: .gregorian)
    if UserDefaults.standard.bool(forKey: "StartMonday") {
      calendar.firstWeekday = 2
    } else {
      calendar.firstWeekday = 1
    }
    
    switch(type) {
    case .monthly:
      let dateComponent = calendar.dateComponents([.year, .month], from: date)
      return "\(dateComponent.month!), \(dateComponent.year!)"
      
    case .weekly:
      let dateComponent = calendar.dateComponents([.year, .month, .weekOfMonth], from: date)
      return "\(dateComponent.year!), \(dateComponent.month!), \(dateComponent.weekOfMonth!)th"
      
    case .daily:
      let dateComponent = calendar.dateComponents([.year, .month, .day], from: date)
      return "\(dateComponent.month!)-\(dateComponent.day!), \(dateComponent.year!)"
    default:
      return ""
        
    }
    
  }
  
}
