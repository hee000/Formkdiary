//
//  PageAddView.swift
//  Formkdiary
//
//  Created by cch on 2022/06/23.
//

import SwiftUI
import CoreData

func yearArray() -> [Date] {
  let now = Date()
  let cal = Calendar.current
  var arr: [Date] = []
  
  for i in -10...10 {
    arr.append(cal.date(byAdding: .year, value: i, to: now)!)
  }

  return arr
}


func monthArray() -> [Date] {
  let now = Date()
  let cal = Calendar.current
  var arr: [Date] = []
  
  let year = cal.component(.year, from: now)

  let yearDate1 = cal.date(from: DateComponents(year: year))!
  let yearDate2 = cal.date(byAdding: .day, value: 1, to: yearDate1)!
  
  for i in 0...11 {
    arr.append(cal.date(byAdding: .month, value: i, to: yearDate2)!)
  }
  
  return arr
}

struct PageAddView: View {
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.managedObjectContext) private var viewContext
  
  @ObservedObject var note: NoteMO

  init(id objectID: NSManagedObjectID, in context: NSManagedObjectContext) {
      if let note = try? context.existingObject(with: objectID) as? NoteMO {
          self.note = note
      } else {
          // if there is no object with that id, create new one
          self.note = NoteMO(context: context)
          try? context.save()
      }
  }
  
  @State var category = 0
  
  @State private var DatePick = Date()
  
  @State var monthIndex: Int = (Calendar.current.component(.month, from: Date()) - 1)
  @State var yearIndex: Int = 10
  
  @State var weekIndex: Int = 0
  
  @State var weekDate: Date = Date()

  @State var date: Date = Date()

  @State var isYear = false
  @State var isMonth = false
  
  let monthSymbols = Calendar.current.monthSymbols
//  let years = Array(Calendar.current.component(.year, from:Calendar.current.date(byAdding: DateComponents(year: -10), to: Date())!)..<Calendar.current.component(.year, from:Calendar.current.date(byAdding: DateComponents(year: 10), to: Date())!))
  
  let years = yearArray()
  let months = monthArray()
  
    var body: some View {
      NavigationView{
        VStack{
          HStack{
            Button{
              self.category = 0
            } label: {
              Text("Monthly")
            }
            .frame(minWidth: 0, maxWidth: .infinity)
                        
            Button{
              self.category = 1
            } label: {
              Text("Weeekly")
            }
            .frame(minWidth: 0, maxWidth: .infinity)

            Button{
              self.category = 2
            } label: {
              Text("Daily")
            }
            .frame(minWidth: 0, maxWidth: .infinity)

            Button{
              self.category = 3
            } label: {
              Text("Memo")
            }
            .frame(minWidth: 0, maxWidth: .infinity)

          } //h
          .frame(height: 50)
          .foregroundColor(.black)
          VStack{
            if self.category == 0 {
              Text("먼슬리 뷰")
              
                HStack(spacing: 0) {
                  Picker(selection: self.$yearIndex, label: Text("")) {
                    ForEach(years.indices, id:\.self) { index in
                      Text(years[index].toString(dateFormat: "yyyy"))
                    }
                  }
                  .frame(width: UIScreen.main.bounds.size.width / 2, height: 100)
                  .pickerStyle(WheelPickerStyle())
                  .contentShape(Rectangle())
                  
                  Picker(selection: self.$monthIndex, label: Text("")) {
                    ForEach(months.indices, id:\.self) { index in
                      Text(months[index].toString(dateFormat: "MM"))
                    }
                  }
                  .frame(width: UIScreen.main.bounds.size.width / 2, height: 100)
                  .pickerStyle(WheelPickerStyle())
                  .contentShape(Rectangle())
                }
          
            Spacer()
              
              Button{
                
                let newPage = PageMO(context: viewContext)
                let newMonthly = MonthlyMO(context: viewContext)
//                
//                let calendar = Calendar.current
//                var dateComponent = DateComponents()
//                dateComponent.year = years[yearIndex]
//                dateComponent.month = monthIndex + 1
//                
                newMonthly.date = intToDate(year: yearIndex, month: monthIndex)
                
                
                newPage.monthly = newMonthly
                newPage.index = Int32(note.pages.count)
//                print("count", note.pages.count)
                
                note.addToPages(newPage)
                  
                CoreDataSave()
                
                presentationMode.wrappedValue.dismiss()
              } label: {
                Text("만들기")
              }
              
            } else if self.category == 1{
              Text("위클리 뷰")
              HStack(spacing: 0) {
                Picker(selection: self.$yearIndex, label: Text("")) {
                  ForEach(years.indices, id:\.self) { index in
                    Text(years[index].toString(dateFormat: "yyyy"))
                      .font(.system(size: 14, weight: .bold))
                  }
                }
                .frame(width: 80,height: 200/6)
                .pickerStyle(WheelPickerStyle())
                
                Spacer()
                
                Picker(selection: self.$monthIndex, label: Text("")) {
                  ForEach(months.indices, id:\.self) { index in
                    Text(months[index].toString(dateFormat: "MM"))
                      .font(.system(size: 12, weight: .bold))
                  }
                }
                .frame(width: 80,height: 200/6)
                .pickerStyle(WheelPickerStyle())
              }
                .frame(width:2*UIScreen.main.bounds.size.width/3)
              
              Divider()
                .frame(width:2*UIScreen.main.bounds.size.width/3)
              
              CalendarView(date: intToDate(year: yearIndex, month: monthIndex), weekDate: $weekDate)
                .frame(width:2*UIScreen.main.bounds.size.width/3, height: 200)
              
              Spacer()
              
              Button{
                let newPage = PageMO(context: viewContext)
                let newWeekly = WeeklyMO(context: viewContext)
                
                newWeekly.date = weekDate
                
                newPage.weekly = newWeekly
                newPage.index = Int32(note.pages.count)
                
                note.addToPages(newPage)
                  
                CoreDataSave()
                
                presentationMode.wrappedValue.dismiss()
              } label: {
                Text("만들기")
              }
            } else if self.category == 2{
              Text("데일리 뷰")
              Spacer()
            } else if self.category == 3{
              Text("메모 뷰")
              Spacer()
            }
          }
          
        } // v
        .navigationTitle("페이지 만들기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button {
              presentationMode.wrappedValue.dismiss()
            } label: {
              Image(systemName: "xmark")
                .foregroundColor(.black)
            }
          }
          
        }//tool
      }//navi
    }
  
  func intToDate(year: Int, month: Int) -> Date{
    let calendar = Calendar.current
    var dateComponent = DateComponents()
    dateComponent.year = calendar.component(.year, from: years[year])
    dateComponent.month = calendar.component(.month, from: months[month])
//    dateComponent.date = calendar.component(.day, from: self.date)
    return calendar.date(from: dateComponent)!
  }
}
