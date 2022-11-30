//
//  MonthlyViewTest.swift
//  Formkdiary
//
//  Created by hee on 2022/10/18.
//

import SwiftUI

struct MonthlyDefaultView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @EnvironmentObject var navigator: Navigator

  @AppStorage("StartMonday") var startMonday: Bool = UserDefaults.standard.bool(forKey: "StartMonday")
  
  @ObservedObject var monthly: MonthlyMO
  let titleVisible: Bool
  
  init(monthly: MonthlyMO, titleVisible: Bool = false) {
    self.monthly = monthly
    self.titleVisible = titleVisible
    self.months = calendar.generateDates(
                    inside: DateInterval(start: monthly.date, end: monthly.date),
                    matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
                  )
  }
  

  @State var isDailyList = false
  @State var dailyListDate = Date()
  @State var dailyActive = false
  @State var dailyObjectID: DailyMO = DailyMO()
  var calendar: Calendar = CalendarModel.shared.calendar

  @State var sellcount = 10
  @State private var dragOffset: CGFloat? = nil
  @State private var Offset: CGFloat = 0

  var body: some View {
    VStack(spacing: 0) {
      ZStack{
        
        HStack {
          ForEach((startMonday ? monWeek : sunWeek), id:\.self){ day in
            Text(day)
              .frame(minWidth: 0, maxWidth: .infinity)
              .frame(height: 50)
//              .foregroundColor(day == "일" ? .red : day == "토" ? .blue : .black)
              .bold()
          }
        }
        .background(Color.customBg)
      }
      
      Divider()
//        .padding(.top)
      
      
      GeometryReader { geo in
        LazyVGrid(columns: Array(repeating: GridItem(.adaptive(minimum: 100), spacing: 0), count: 7), spacing: 1) {
          ForEach(months, id: \.self) { month in
            ForEach(days(for: month), id: \.self) { date in
              if calendar.isDate(date, equalTo: month, toGranularity: .month) {
                Button{
//                  withAnimation{
                  if isDailyList {
                    if date == dailyListDate {
                      withAnimation{
                        isDailyList = false
                      }
                    } else {
                      dailyListDate = date
                    }
                    
                  } else {
                    withAnimation{
                      isDailyList = true
                      dailyListDate = date
                    }
                  }
                } label: {
                  VStack(alignment: .leading, spacing: 1) {
                    Text("\(date.toString(dateFormat: "dd"))")
                      .frame(maxWidth: .infinity, alignment: .center)
                      .bold()
                      .foregroundColor(Color.customText)
                    GeometryReader{ outer in
                      VStack(spacing: 3.5) {
                        if let dailies: [DailyMO] = monthly.dailies.toArray().filter({ DailyMO in
                          calendar.isDate(DailyMO.date, equalTo: date, toGranularity: .day)
                        }).sorted(by: { $0.createdAt.compare($1.createdAt) == .orderedAscending }), !dailies.isEmpty {
                          
                          ForEach(dailies[0..<(dailies.count > sellcount ? sellcount : dailies.count)]) { daily in
                            Text(daily.text)
                              .foregroundColor(Color.customText)
                              .font(.system(size: 10, weight: .regular))
                              .lineLimit(1)
                              .padding(.leading, 3)
                              .frame(maxWidth: .infinity, alignment: .leading)
                            //                            .background(Color.gray.opacity(0.5))
                              .background(Color.customTextLight)
                              .cornerRadius(3)
                              .padding([.leading, .trailing], 5)
                            //                            .cornerRadius(3)
//                              .frame(height: 10)
                          }
                          
                          if dailies.count > sellcount {
                            //                          Text("+\(dailies.count - 4)")
                            Text("...")
                              .foregroundColor(Color.customText)
                              .font(.system(size: 10, weight: .regular))
                              .padding(.leading, 3)
                              .frame(maxWidth: .infinity, alignment: .leading)
                              .padding([.leading, .trailing], 5)
                          }
                        }
                        Spacer()
                          .task{
                            sellcount = Int(outer.size.height / 15) > 1 ? Int(outer.size.height / 15) - 1 : 1
                          }
                          .onChange(of: outer.size.height) { V in
                            sellcount = Int(outer.size.height / 15) > 1 ? Int(outer.size.height / 15) - 1 : 1
                          }
                      }//v
//                        sellcount = Int(outer.size.height / 10) > 1 ? Int(outer.size.height / 10) - 1 : 1
//                      }
                    }//outerGeo
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                  }
                  .frame(height: geo.size.height/6)
                  .background(Color.customBg)
                  .foregroundColor(Color.customText)
                  .clipped()
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
                .background(Color.customBg)
                .foregroundColor(Color.customTextLight)
              }
            }
          }//for
        }//grid
//        .frame(maxHeight: .infinity)
//        .background(Color.customBg)
        
      }//geo
      .background(Color.customBg)
//      .navigationDestination(isPresented: $dailyActive) {
//        DailyViewWithoutPage(daily: dailyObjectID)
//          .onDisappear{
//            isDailyList = true
//          }
//      }
      if isDailyList {
        GeometryReader { gestureGeo in
          VStack(alignment: .leading) {
            HStack{
              Text("\(dailyListDate.toString(dateFormat: "d")). \(startMonday ? monWeek[calendar.dateComponents([.weekday], from: dailyListDate).weekday! - 1] : sunWeek[calendar.dateComponents([.weekday], from: dailyListDate).weekday! - 1])")
                .foregroundColor(Color.customText)
                .font(.title2)
              Spacer()
              Button{
                let newdaily = DailyMO(context: viewContext)
                newdaily.date = dailyListDate
                newdaily.monthly = monthly
                CoreDataSave()
                //            dailyObjectID = newdaily
                //              isDailyList = false
                //            dailyActive = true
                navigator.path.append(Route.daily(newdaily))
                
              } label: {
                Image(systemName: "plus.circle")
                  .foregroundColor(Color.customText)
              }
            }
            
            VStack{
              if let dailies: [DailyMO] = monthly.dailies.toArray().filter({ DailyMO in
                calendar.isDate(DailyMO.date, equalTo: dailyListDate, toGranularity: .day)
              }).sorted(by: { $0.createdAt.compare($1.createdAt) == .orderedAscending }), !dailies.isEmpty {
                List{
                  ForEach(dailies) { daily in
                    Button{
                      //                  dailyObjectID = daily
                      //                    isDailyList = false
                      //                  dailyActive = true
//                      print(daily)
                      navigator.path.append(Route.daily(daily))
                    } label: {
                      HStack{
                        Circle()
                          .fill(Color.customTextLight)
                          .frame(width: 5, height: 5)
                        Text(daily.text)
                          .lineLimit(1)
                          .font(.system(size: 18, weight: .regular))
                          .frame(maxWidth: .infinity, alignment: .leading)
                          .bold()
                          .foregroundColor(Color.customText)
                      }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.customBg)
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
                .scrollContentBackground(.hidden)
                .background(Color.customBg)
                .listStyle(.plain)
                Spacer()
              } else {
                Text("데일리가 비었습니다.")
                  .foregroundColor(Color.customText)
              }
            } //v
            .frame(maxWidth: .infinity, maxHeight: .infinity)
          }//v
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding()
          .ignoresSafeArea()
          .presentationDetents([.fraction(0.4), .fraction(0.5), .fraction(0.6), .fraction(0.7), .fraction(0.8)])
          .background(Color.customBg)
          .task{
            dragOffset = gestureGeo.size.height
            Offset = gestureGeo.size.height
          }
        }//geo
          .frame(height: dragOffset)
      } //if
    }//v
    .gesture(
      DragGesture()
        .onChanged { gesture in
          if dragOffset != nil {
            withAnimation {
              if Offset - gesture.translation.height >= 0 {
                if Offset - gesture.translation.height <= Offset {
                  dragOffset = Offset - gesture.translation.height
                } else {
                  dragOffset = Offset
                }
//                dragOffset = Offset - gesture.translation.height
              } else {
                dragOffset = nil
                isDailyList = false
              }
            }
          }
//          print(gesture.translation.height)
        }
        .onEnded { gesture in
          withAnimation{
            if let dragOffsetz = dragOffset, dragOffsetz < 150 {
              dragOffset = nil
              isDailyList = false
            } else {
              dragOffset = Offset
            }
          }
        }
    )
  }

//  private var months: [Date] {
//    calendar.generateDates(
//      inside: DateInterval(start: monthly.date, end: monthly.date),
//      matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
//    )
//  }
  
  private var months: [Date]


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

