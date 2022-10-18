//
//  MonthlyViewTest.swift
//  Formkdiary
//
//  Created by hee on 2022/10/18.
//

import SwiftUI

struct MonthlyDefaultView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @EnvironmentObject var pageNavi: PageNavi
  @AppStorage("StartMonday") var startMonday: Bool = UserDefaults.standard.bool(forKey: "StartMonday")
  
  @ObservedObject var monthly: MonthlyMO
  let titleVisible: Bool
  
  init(monthly: MonthlyMO, titleVisible: Bool = false) {
    self.monthly = monthly
    self.titleVisible = titleVisible
  }
  

  @State var isDailyList = false
  @State var dailyListDate = Date()
  @State var dailyActive = false
  @State var dailyObjectID: DailyMO = DailyMO()
  var calendar: Calendar = CalendarModel.shared.calendar

  var body: some View {
    VStack(spacing: 0) {
      ZStack{
        if dailyActive {
          NavigationLink(destination: DailyViewWithoutPage(daily: dailyObjectID).onDisappear{
            isDailyList = true
          }, isActive: $dailyActive) {}
        }
        
        HStack {
          ForEach((startMonday ? monWeek : sunWeek), id:\.self){ day in
            Text(day)
              .frame(minWidth: 0, maxWidth: .infinity)
              .frame(height: 50)
//              .foregroundColor(day == "일" ? .red : day == "토" ? .blue : .black)
              .bold()
          }
        }
      }
      
      Divider()
//        .padding(.top)
      
      
      GeometryReader { geo in
        LazyVGrid(columns: Array(repeating: GridItem(.adaptive(minimum: 100), spacing: 0), count: 7), spacing: 1) {
          ForEach(months, id: \.self) { month in
            ForEach(days(for: month), id: \.self) { date in
              if calendar.isDate(date, equalTo: month, toGranularity: .month) {
                Button{
                  if let daily: DailyMO = monthly.dailies.toArray().first(where: { DailyMO in
                    calendar.isDate(date, equalTo: DailyMO.date, toGranularity: .day)
                  }) { // 있으면
                    dailyListDate = date
                    isDailyList.toggle()
                  } else { // 없으면
                    dailyListDate = date
                    isDailyList.toggle()
//                    let newdaily = DailyMO(context: viewContext)
//                    newdaily.date = date
//                    newdaily.monthly = monthly
//                    CoreDataSave()
//                    dailyObjectID = newdaily
//                    dailyActive = true
                  }

                } label: {
                  VStack(alignment: .leading, spacing: 1) {
                    Text("\(date.toString(dateFormat: "dd"))")
                      .frame(maxWidth: .infinity, alignment: .center)
                      .bold()
                    VStack(spacing: 3.5) {
                      if let dailies: [DailyMO] = monthly.dailies.toArray().filter({ DailyMO in
                        calendar.isDate(DailyMO.date, equalTo: date, toGranularity: .day)
                      }).sorted(by: { $0.createdAt.compare($1.createdAt) == .orderedAscending }), !dailies.isEmpty {

                        ForEach(dailies[0..<(dailies.count >= 5 ? 4 : dailies.count)]) { daily in
                          Text(daily.text)
                            .font(.system(size: 10, weight: .regular))
                            .lineLimit(1)
                            .padding(.leading, 3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(3)
                            .padding([.leading, .trailing], 5)
//                            .cornerRadius(3)
                        }
                        
                        if dailies.count >= 5 {
//                          Text("+\(dailies.count - 4)")
                          Text("...")
                            .font(.system(size: 10, weight: .regular))
                            .padding(.leading, 3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.leading, .trailing], 5)
                        }
                      }
                      Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                  }
                  .frame(height: geo.size.height/6)
                  .background(Color.white)
                  .foregroundColor(.black)
                }
              } else {
                VStack(alignment: .leading, spacing: 0) {
                  Text("\(date.toString(dateFormat: "dd"))")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .bold()
                    .padding(.bottom)

                  Spacer().frame(minWidth: 0, maxWidth: .infinity)
                }
                .frame(height: geo.size.height/6)
                .background(Color.white)
                .foregroundColor(.gray)
              }
            }
          }//for
        }//grid
//        .frame(maxHeight: .infinity)
        .background(.gray.opacity(0.2))
//        .ignoresSafeArea()
      }//geo
//      .ignoresSafeArea()
    }//v
    .sheet(isPresented: $isDailyList) {
      VStack(alignment: .leading) {
        HStack{
          Text("\(dailyListDate.toString(dateFormat: "d"))일. \(startMonday ? monWeek[calendar.dateComponents([.weekday], from: dailyListDate).weekday! - 1] : sunWeek[calendar.dateComponents([.weekday], from: dailyListDate).weekday! - 1])")
            .bold()
            .font(.title2)
          Spacer()
          Button{
            let newdaily = DailyMO(context: viewContext)
            newdaily.date = dailyListDate
            newdaily.monthly = monthly
            CoreDataSave()
            dailyObjectID = newdaily
            isDailyList = false
            dailyActive = true
          } label: {
            Image(systemName: "plus.circle")
          }
        }
        
        VStack{
          if let dailies: [DailyMO] = monthly.dailies.toArray().filter({ DailyMO in
            calendar.isDate(DailyMO.date, equalTo: dailyListDate, toGranularity: .day)
          }).sorted(by: { $0.createdAt.compare($1.createdAt) == .orderedAscending }), !dailies.isEmpty {
            List{
              ForEach(dailies) { daily in
                Button{
                  dailyObjectID = daily
                  isDailyList = false
                  dailyActive = true
                } label: {
                  HStack{
                    Circle()
                      .fill(Color.gray)
                      .frame(width: 5, height: 5)
                    Text(daily.text)
                      .font(.system(size: 18, weight: .regular))
                      .frame(maxWidth: .infinity, alignment: .leading)
                      .bold()
                  }
                }
                .listRowSeparator(.hidden)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                  Button(role: .destructive) {
                    viewContext.delete(daily)
                    CoreDataSave()
                    print("삭제")
                  } label: {
                    Label("Delete", systemImage: "trash.fill")
                  }
                }//swipe
              }//for
            }//list
            .listStyle(.plain)
            Spacer()
          } else {
            Text("데일리가 비었습니다.")
          }
        } //v
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }//v
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding()
      .ignoresSafeArea()
      .presentationDetents([.fraction(0.4), .fraction(0.5), .fraction(0.6), .fraction(0.7), .fraction(0.8)])
    }//sheet
    .onAppear{
      if (titleVisible) {
        pageNavi.title = self.monthly.page!.title
        pageNavi.pageObjectID = self.monthly.page!.objectID
      }
    }
    .onChange(of: titleVisible) { V in
      if V {
        pageNavi.title = self.monthly.page!.title
        pageNavi.pageObjectID = self.monthly.page!.objectID
      }
    }
    .onChange(of: monthly.page!.title) { V in
      print(V)
      pageNavi.title = self.monthly.page!.title
      pageNavi.pageObjectID = self.monthly.page!.objectID
    }
  }

  private var months: [Date] {
    calendar.generateDates(
      inside: DateInterval(start: monthly.date, end: monthly.date),
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

