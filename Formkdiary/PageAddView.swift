//
//  PageAddView.swift
//  Formkdiary
//
//  Created by cch on 2022/06/23.
//

import SwiftUI
import CoreData

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
  
  @State var monthIndex: Int = 0
  @State var yearIndex: Int = 10
  
  @State var weekIndex: Int = 0

  

  let monthSymbols = Calendar.current.monthSymbols
  let years = Array(Calendar.current.component(.year, from:Calendar.current.date(byAdding: DateComponents(year: -10), to: Date())!)..<Calendar.current.component(.year, from:Calendar.current.date(byAdding: DateComponents(year: 10), to: Date())!))
  
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
                    ForEach(0..<self.years.count) { index in
                      Text(String(self.years[index]))
                    }
                  }
                  .pickerStyle(WheelPickerStyle())
                  .frame(width: UIScreen.main.bounds.size.width / 2, height: 80)
                  .compositingGroup()
                  .clipped(antialiased: true)
                  .contentShape(Rectangle())

                  Picker(selection: self.$monthIndex, label: Text("")) {
                    ForEach(0..<self.monthSymbols.count) { index in
                      Text(self.monthSymbols[index])
                    }
                  }
                  .pickerStyle(WheelPickerStyle())
//                  .compositingGroup()
                  .frame(width: UIScreen.main.bounds.size.width / 2, height: 80)
                  .compositingGroup()
                  .clipped(antialiased: true)
                  .contentShape(Rectangle())
                }
          
            Spacer()
              
              Button{
                
                let newPage = PageMO(context: viewContext)
                let newMonthly = MonthlyMO(context: viewContext)
                
                let calendar = Calendar.current
                var dateComponent = DateComponents()
                dateComponent.year = years[yearIndex]
                dateComponent.month = monthIndex + 1
                
                newMonthly.date = calendar.date(from: dateComponent)!
                
                newPage.monthly = newMonthly
                newPage.index = Int16(note.pages.count)
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
                    ForEach(0..<self.years.count) { index in
                        Text(String(self.years[index]))
                    }
                }
                  .pickerStyle(MenuPickerStyle())
                  .accentColor(.black)
                Text(",")
                Picker(selection: self.$monthIndex, label: Text("")) {
                    ForEach(0..<self.monthSymbols.count) { index in
                        Text(self.monthSymbols[index])
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .accentColor(.black)
                
                Spacer()
              }
                .frame(width:2*UIScreen.main.bounds.size.width/3)
              
              Divider()
                .frame(width:2*UIScreen.main.bounds.size.width/3)
              
              PageAddWeeeklyCalView(weekIndex: $weekIndex)
                .frame(width:2*UIScreen.main.bounds.size.width/3, height: 200)
                
              
              Spacer()
              Button{
                let newPage = PageMO(context: viewContext)
                let newWeekly = WeeklyMO(context: viewContext)
                
                let calendar = Calendar.current
                var dateComponent = DateComponents()
                dateComponent.year = 2022
                dateComponent.month = 7
                dateComponent.day = weekIndex
                
                newWeekly.date = calendar.date(from: dateComponent)!
                
                newPage.weekly = newWeekly
                newPage.index = Int16(note.pages.count)
                
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
}
