//
//  WeeklyTest.swift
//  Formkdiary
//
//  Created by cch on 2022/09/20.
//

import SwiftUI

struct WeeklyDefaultView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @EnvironmentObject var navigator: Navigator

  @ObservedObject var weekly: WeeklyMO
  @AppStorage("StartMonday") var startMonday: Bool = UserDefaults.standard.bool(forKey: "StartMonday")
  var calendar: Calendar = CalendarModel.shared.calendar
  var week: [Date]
  
  let titleVisible: Bool
  
  init(weekly: WeeklyMO, titleVisible: Bool = false) {
    self.weekly = weekly
    self.titleVisible = titleVisible

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
          
          LazyVGrid(columns: Array(repeating: GridItem(), count: Int(weekly.style) + 1)) {
            ForEach(Array(zip(week.indices, week)), id: \.1) { index, date in
              Button{
                  if let daily = dailes.first(where: { DailyMO in
                    calendar.component(.day, from: DailyMO.date) == calendar.component(.day, from: date)
                  }) { // 있으면
                    navigator.path.append(.daily(daily))
                  } else { // 없으면
                    print("bb")
                    let newdaily = DailyMO(context: viewContext)
                    newdaily.date = date
                    newdaily.weekly = self.weekly
                    CoreDataSave()
                    navigator.path.append(.daily(newdaily))
                  }
                } label: {
                  VStack{
                    HStack{
                      Text("\(date.toString(dateFormat: "dd")) \(startMonday ? monWeek[index] : sunWeek[index])")
                      VStack{
                        Divider()
                          .background(Color.customTextLight)
                      }
                    }.padding(.top)
                    
                    
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
//                .background(Color.customBg)
//                .foregroundColor(Color.customText)
//                .cornerRadius(5)
//                .clipped()
//                .shadow(color: Color.customTextLight, radius: 2)
            } //for
          } //grid
          .padding()
        } // scroll
        .background(Color.customBg)
        .foregroundColor(Color.customText)
      } // geo
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

struct WeeklyDefaultView_Previews: PreviewProvider {
  static var weekly: WeeklyMO {
    let weekly = WeeklyMO(context: PersistenceController.shared.context)
    weekly.date = Date()
    return weekly
  }
  static var previews: some View {
    WeeklyDefaultView(weekly: weekly)
//      .task {
//        weekly.date = Date()
//      }
  }
}
