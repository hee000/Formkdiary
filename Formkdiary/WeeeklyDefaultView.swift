//
//  WeeeklyDefaultView.swift
//  Formkdiary
//
//  Created by cch on 2022/07/02.
//

import SwiftUI
import CoreData

struct WeeeklyDefaultView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.presentationMode) var presentationMode

  @ObservedObject var weeekly: WeeklyMO

  let week = ["일", "월", "화", "수", "목", "금", "토"]
  var day: Int
  var start: Int
  var last: Int
  let columns = [
      GridItem(.flexible(), spacing: 1),
      GridItem(.flexible(), spacing: 1)
      ]
  var cal = Calendar.current
  let title: String
  
  @State var dailyActive = false
  @State var dailyObjectID: NSManagedObjectID = NSManagedObjectID()

  
  init(id objectID: NSManagedObjectID, in context: NSManagedObjectContext) {
    let calendar = Calendar.current
    var dateComponent: DateComponents
    
      if let weeekly = try? context.existingObject(with: objectID) as? WeeklyMO {
        dateComponent = calendar.dateComponents([.year, .month, .day, .weekOfMonth], from: weeekly.date)
        self.weeekly = weeekly
      } else {
        // if there is no object with that id, create new one
        let newWeeekly = WeeklyMO(context: context)
        dateComponent = calendar.dateComponents([.year, .month, .day, .weekOfMonth], from: newWeeekly.date)
        self.weeekly = newWeeekly
        try? context.save()
      }
    
    title = "\(dateComponent.year!), \(dateComponent.month!)월, \(dateComponent.weekOfMonth!)주"
    let month = calendar.date(from: dateComponent)!

    
    start = calendar.component(.weekday, from: month)
    day = calendar.component(.day, from: month)
    
    last = calendar.range(of: .day, in: .month, for: month)?.last ?? 30
  }
  
    var body: some View {
      GeometryReader { geo in
        ScrollView{
//          HStack {
//            ForEach(0..<7){ index in
//              Text(week[index])
//                .frame(minWidth: 0, maxWidth: .infinity)
//            }
//          }
          
//          Divider()
          
          let dailes = weeekly.dailies.allObjects as! [DailyMO]
          let calendar = Calendar.current
          if dailyActive {
            NavigationLink(destination: DailyView(id: dailyObjectID, in: viewContext), isActive: $dailyActive) {}
          }
          
          LazyVGrid(columns: self.columns, spacing: 2){
            ForEach(0..<7, id:\.self) { index in
              Button{
                if let daily = dailes.first(where: { DailyMO in
                  calendar.component(.day, from: DailyMO.date) == calendar.component(.day, from: calendar.date(byAdding: DateComponents(day: index - self.start), to: self.weeekly.date)!)
                }) { // 있으면
                  dailyObjectID = daily.objectID
                  dailyActive = true
                } else { // 없으면
                  let newdaily = DailyMO(context: viewContext)
                  newdaily.date = calendar.date(byAdding: DateComponents(day: index - self.start), to: self.weeekly.date)!
                  newdaily.weekly = self.weeekly
                  CoreDataSave()
                  dailyObjectID = newdaily.objectID
                  dailyActive = true
                }
                
              } label: {
                VStack(alignment: .leading, spacing: 1) {
                  Text("\(day + index)일 \(week[(start + index) % 7])요일")
//                    .frame(maxWidth: .infinity, alignment: .leading)

                  if let daily = dailes.first { DailyMO in
                    calendar.component(.day, from: DailyMO.date) == calendar.component(.day, from: calendar.date(byAdding: DateComponents(day: index - self.start), to: self.weeekly.date)!)
                  } {
                    Text(daily.text)
                      .font(.system(size: 10, weight: .regular))
                      .lineLimit(nil)
                      .multilineTextAlignment(.leading)
                      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                  } else {
                    Text("")
                      .frame(maxWidth: .infinity, maxHeight: .infinity)
                  }
                }
                .frame(height: UIScreen.main.bounds.size.height / 3)
                .background(Color.white)
                .foregroundColor(.black)
              }
            }//for
          } //grid
          .background(Color.gray)
        } //scroll
      } //geo
      .navigationTitle(title)
      .navigationBarBackButtonHidden(true)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            presentationMode.wrappedValue.dismiss()
          } label: {
            Image(systemName: "chevron.left")
              .foregroundColor(.black)
          }
        }
      }//toolbar

    }
}

