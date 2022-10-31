import SwiftUI


extension Calendar {
  func generateDates(inside interval: DateInterval, matching components: DateComponents) -> [Date] {
    var dates: [Date] = []
    dates.append(interval.start)

    enumerateDates(startingAfter: interval.start, matching: components, matchingPolicy: .nextTime) { date, _, stop in
      if let date = date {
        if date < interval.end {
          dates.append(date)
        } else {
          stop = true
        }
      }
    }

//    print(dates)
    return dates
  }
}

struct PageAddCalView: View {
  var calendar: Calendar = CalendarModel.shared.calendar

  @AppStorage("StartMonday") var startMonday: Bool = UserDefaults.standard.bool(forKey: "StartMonday")
  @AppStorage("EnglishDay") var englishDay: Bool = UserDefaults.standard.bool(forKey: "EnglishDay")
  
  let interval: DateInterval

  @State var selected: [Date] = []
  @Binding var weekDate: Date?

  let pageType: PageType

  init(date: Date, weekDate: Binding<Date?>, pageType: PageType = .weekly) {
    self.interval = DateInterval(start: date, end: date)
    _weekDate = weekDate
    print(date.toString(dateFormat: "yyyy-MM-dd"))
    
//    calendar =  Calendar(identifier: .gregorian)
//
//    if UserDefaults.standard.bool(forKey: "StartMonday") {
//      calendar.firstWeekday = 2
//    } else {
//      calendar.firstWeekday = 1
//    }
    
    self.pageType = pageType
  }

  var body: some View {
//    GeometryReader { geo in
      VStack {
        HStack {
          ForEach((startMonday ? monWeek : sunWeek), id:\.self){ day in
            Text(englishDay ? "\(day.first!)" : day)
              .frame(minWidth: 0, maxWidth: .infinity)
              .frame(height: 20)
          }
        }
        
        LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
          ForEach(months, id: \.self) { month in
            ForEach(days(for: month), id: \.self) { date in
              if calendar.isDate(date, equalTo: month, toGranularity: .month) {
//                content(date)
                Button{
                  weekDate = date
                  switch(pageType) {
                  case.weekly:
                    selected = week(for: date)
                    
                  case .daily:
                    selected = [date]
                    
                  default:
                    break
                  }

                } label: {
                  Text("\(date.toString(dateFormat: "dd"))")
                    .frame(height: 25)
                    .frame(maxWidth: .infinity)
                    .background(Color.customBg)
                    .foregroundColor(Color.customText)
                    .overlay(selected.contains(date) ? Rectangle().fill(Color.customTextLight.opacity(0.4)).cornerRadius(5) : nil)
                }
              } else {
                Text("\(date.toString(dateFormat: "dd"))")
                  .disabled(true)
                  .frame(height: 25)
                  .frame(maxWidth: .infinity)
                  .background(Color.customBg)
                  .foregroundColor(Color.customTextLight)
                  .overlay(selected.contains(date) ? Rectangle().fill(Color.customTextLight.opacity(0.4)).cornerRadius(5) : nil)
              }
            }
          }//for
        }//grid
      }//v
//    }//geo
    .onAppear{
      guard let date = weekDate else { return }
      switch(pageType) {
      case.weekly:
        selected = week(for: date)
        
      case .daily:
        selected = [date]
        
      default:
        break
      }
      
    }
  }

  private var months: [Date] {
    calendar.generateDates(
      inside: interval,
      matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
    )
  }


  private func days(for month: Date) -> [Date] {
    guard
      let monthInterval = calendar.dateInterval(of: .month, for: month),
      let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
      let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end)
    else { return [] }
    return calendar.generateDates(
      inside: DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end),
      matching: DateComponents(hour: 0, minute: 0, second: 0)
    )
  }
  
  private func week(for day: Date) -> [Date] {
    print("ddd")
    guard
      let dayInterval = calendar.dateInterval(of: .weekOfMonth, for: day)
    else { return [] }
    return calendar.generateDates(
      inside: DateInterval(start: dayInterval.start, end: dayInterval.end),
      matching: DateComponents(hour: 0, minute: 0, second: 0)
    )
  }
}

