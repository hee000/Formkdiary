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

struct CalendarView: View {
  var calendar: Calendar

  @AppStorage("StartMonday") var startMonday: Bool = UserDefaults.standard.bool(forKey: "StartMonday")
  
  let interval: DateInterval

  @State var selected: [Date] = []
  @Binding var weekDate: Date


  init(date: Date, weekDate: Binding<Date>) {
    self.interval = DateInterval(start: date, end: date)
    _weekDate = weekDate
    print(date.toString(dateFormat: "yyyy-MM-dd"))
    
    calendar =  Calendar(identifier: .gregorian)
    
    if UserDefaults.standard.bool(forKey: "StartMonday") {
      calendar.firstWeekday = 2
    } else {
      calendar.firstWeekday = 1
    }
  }

  var body: some View {
    VStack {
      HStack {
        ForEach((startMonday ? monWeek : sunWeek), id:\.self){ day in
          Text(day)
            .frame(minWidth: 0, maxWidth: .infinity)
        }
      }
      
      GeometryReader { geo in
        LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
          ForEach(months, id: \.self) { month in
            ForEach(days(for: month), id: \.self) { date in
              if calendar.isDate(date, equalTo: month, toGranularity: .month) {
//                content(date)
                Button{
                  weekDate = date
                  selected = week(for: date)
                } label: {
                  Text("\(date.toString(dateFormat: "dd"))")
                    .frame(height: geo.size.height/6)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .overlay(selected.contains(date) ? Rectangle().fill(Color.black.opacity(0.4)).cornerRadius(10) : nil)
                }
              } else {
                Text("\(date.toString(dateFormat: "dd"))")
                  .disabled(true)
                  .frame(height: geo.size.height/6)
                  .frame(maxWidth: .infinity)
                  .background(Color.white)
                  .foregroundColor(.gray)
                  .overlay(selected.contains(date) ? Rectangle().fill(Color.black.opacity(0.4)).cornerRadius(10) : nil)
              }
            }
          }
        }
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
    guard
      let dayInterval = calendar.dateInterval(of: .weekOfMonth, for: day)
//      let dayInterval = DateInterval(start: day, duration: 60*60*24*7)
//      let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
//      let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end)
    else { return [] }
    return calendar.generateDates(
      inside: DateInterval(start: dayInterval.start, end: dayInterval.end),
      matching: DateComponents(hour: 0, minute: 0, second: 0)
    )
  }
}

