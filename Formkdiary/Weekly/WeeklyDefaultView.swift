//
//  WeeklyTest.swift
//  Formkdiary
//
//  Created by cch on 2022/09/20.
//

import SwiftUI

struct WeeklyDefaultView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @EnvironmentObject var pageNavi: PageNavi

  @ObservedObject var weekly: WeeklyMO
  @AppStorage("StartMonday") var startMonday: Bool = UserDefaults.standard.bool(forKey: "StartMonday")
  var calendar: Calendar = CalendarModel.shared.calendar
  var column: Int
  var week: [Date]
  
  let titleVisible: Bool
  
  @State var dailyActive = false
  @State var dailyObj: DailyMO = DailyMO()
  
  init(weekly: WeeklyMO, titleVisible: Bool = false) {
    self.weekly = weekly
    
    self.column = layoutToMonthlyStyle(weekly.layout).rawValue
    self.titleVisible = titleVisible

    
//    self.calendar =  Calendar(identifier: .gregorian)
//    if UserDefaults.standard.bool(forKey: "StartMonday") {
//      self.calendar.firstWeekday = 2
//    } else {
//      self.calendar.firstWeekday = 1
//    }
    
    let dateComponent = calendar.dateComponents([.year, .month, .weekOfMonth], from: weekly.date)
    
    let dayInterval = calendar.dateInterval(of: .weekOfMonth, for: weekly.date)!
    self.week = calendar.generateDates(
      inside: DateInterval(start: dayInterval.start, end: dayInterval.end),
      matching: DateComponents(hour: 0, minute: 0, second: 0)
    )
  }
  
    var body: some View {
      GeometryReader { geo in
        ScrollView{
          let dailes = weekly.dailies.allObjects as! [DailyMO]
          if dailyActive {
            NavigationLink(destination: DailyViewWithoutPage(daily: dailyObj), isActive: $dailyActive) {}
          }
          
          LazyVGrid(columns: Array(repeating: GridItem(), count: column)) {
            ForEach(Array(zip(week.indices, week)), id: \.1) { index, date in
              Button{
                  if let daily = dailes.first(where: { DailyMO in
                    calendar.component(.day, from: DailyMO.date) == calendar.component(.day, from: date)
                  }) { // 있으면
                    print("aa")
                    dailyObj = daily
                    dailyActive = true
                  } else { // 없으면
                    print("bb")
                    let newdaily = DailyMO(context: viewContext)
                    newdaily.date = date
                    newdaily.weekly = self.weekly
                    CoreDataSave()
                    dailyObj = newdaily
                    dailyActive = true
                  }
                } label: {
                  VStack{
                    Text("\(date.toString(dateFormat: "dd"))일 \(startMonday ? monWeek[index] : sunWeek[index])요일")
                      .padding(.top)
                    
                    if let daily = dailes.first(where: { DailyMO in
                      calendar.component(.day, from: DailyMO.date) == calendar.component(.day, from: date)
                    }) { // 있으면
                      Text(daily.text)
                        .font(.system(size: 10, weight: .regular))
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding()
                    } else { // 없으면
                      Text("")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                  }//v
                } //button label
                .frame(height: UIScreen.main.bounds.size.height / 3)
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(5)
                .clipped()
                .shadow(color: Color.black.opacity(0.2), radius: 2)
            } //for
          } //grid
          .padding()
        } // scroll
      } // geo
      .onAppear {
        if titleVisible {
          pageNavi.title = self.weekly.page!.title
          pageNavi.pageObjectID = self.weekly.page!.objectID
        }
      }
      .onChange(of: titleVisible) { V in
        if V {
          pageNavi.title = self.weekly.page!.title
          pageNavi.pageObjectID = self.weekly.page!.objectID
        }
      }
    }
  
  private func dateToWeek(for day: Date) -> [Date] {
    guard
      let dayInterval = calendar.dateInterval(of: .weekOfMonth, for: day)
    else { return [] }
    return calendar.generateDates(
      inside: DateInterval(start: dayInterval.start, end: dayInterval.end),
      matching: DateComponents(hour: 0, minute: 0, second: 0)
    )
  }
}
