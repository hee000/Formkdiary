//
//  MonthlyDefaultView.swift
//  Formkdiary
//
//  Created by cch on 2022/07/01.
//

import SwiftUI
import CoreData

struct MonthlyDefaultView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.presentationMode) var presentationMode
  @EnvironmentObject var pageNavi: PageNavi

  @AppStorage("StartMonday") var startMonday: Bool = UserDefaults.standard.bool(forKey: "StartMonday")
  
  @ObservedObject var montly: MonthlyMO
  
  var before: Int
  var start: Int
  var last: Int

  let week = ["일", "월", "화", "수", "목", "금", "토"]
  
  let height = (UIScreen.main.bounds.size.height / 8)
  let titleVisible: Bool
  
  @State var dailyActive = false
  @State var dailyObjectID: DailyMO = DailyMO()
  
  init(_monthly: MonthlyMO, titleVisible: Bool = false) {
    self.titleVisible = titleVisible
    let calendar = Calendar.current
    var dateComponent: DateComponents
    
//      if let montly = try? context.existingObject(with: objectID) as? MonthlyMO {
//        dateComponent = calendar.dateComponents([.year, .month], from: montly.date)
//        self.montly = montly
//      } else {
//        // if there is no object with that id, create new one
//        let newMonthly = MonthlyMO(context: context)
//        dateComponent = calendar.dateComponents([.year, .month], from: newMonthly.date)
//        self.montly = newMonthly
//        try? context.save()
//      }
    dateComponent = calendar.dateComponents([.year, .month], from: _monthly.date)
    self.montly = _monthly
//    dateComponent = calendar.dateComponents([.year, .month], from: montly.date)
//    self
    
    
    let month = calendar.date(from: dateComponent)!
    
    if !UserDefaults.standard.bool(forKey: "StartMonday") {
      start = calendar.component(.weekday, from: month)
    } else {
      start = (calendar.component(.weekday, from: month) - 1) < 0 ? 7 : calendar.component(.weekday, from: month) - 1
    }
    
//    start = calendar.component(.weekday, from: month)
    last = calendar.range(of: .day, in: .month, for: month)?.last ?? 30
    
    let beforeMonthLastDay = calendar.date(byAdding: DateComponents(day: -1), to: month) ?? Date()
    before = calendar.component(.day, from: beforeMonthLastDay)
  }

  let columns = [
    GridItem(.adaptive(minimum: 100), spacing: 0),
    GridItem(.adaptive(minimum: 100), spacing: 0),
    GridItem(.adaptive(minimum: 100), spacing: 0),
    GridItem(.adaptive(minimum: 100), spacing: 0),
    GridItem(.adaptive(minimum: 100), spacing: 0),
    GridItem(.adaptive(minimum: 100), spacing: 0),
    GridItem(.adaptive(minimum: 100), spacing: 0)
      ]
  
    var body: some View {
      GeometryReader { geo in
        VStack(spacing: 0) {
          HStack {
            ForEach((startMonday ? monWeek : sunWeek), id:\.self){ day in
              Text(day)
//                .foregroundColor(.black)
                .foregroundColor(day == "일" ? .red : day == "토" ? .blue : .black)
//                .foregroundColor(week[index] == "토" ? .blue : .black)
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 50)
            }
          }
          
          Divider()
          
          
          let dailes = montly.dailies.allObjects as! [DailyMO]
          let calendar = Calendar.current
          if dailyActive {
            NavigationLink(destination: DailyViewWithoutPage(daily: dailyObjectID), isActive: $dailyActive) {}
          }
//          NavigationLink(destination: DailyView(id: dailyObjectID, in: viewContext, monthly: montly), isActive: $dailyActive) {}
          
          GeometryReader { calgeo in
            LazyVGrid(columns: self.columns, spacing: 1){
              ForEach(1..<43, id:\.self) { index in
                if index < self.start {
                  VStack(alignment: .leading, spacing: 0) {
                    Text("\(self.before - self.start + 1 + index)")
                      .frame(maxWidth: .infinity, alignment: .center)
                      .padding(.bottom)
                    
                    Spacer().frame(minWidth: 0, maxWidth: .infinity)
                  }
                  .frame(height: calgeo.size.height/6)
                  .background(Color.white)
                  .foregroundColor(.gray)
                  
                } else if (index - self.start) < self.last {
                  Button{
                    if let daily = dailes.first(where: { DailyMO in
                      calendar.component(.day, from: DailyMO.date) == calendar.component(.day, from: calendar.date(byAdding: DateComponents(day: index - self.start), to: self.montly.date)!)
                    }) { // 있으면
                      dailyObjectID = daily
                      dailyActive = true
                    } else { // 없으면
                      let newdaily = DailyMO(context: viewContext)
                      newdaily.date = calendar.date(byAdding: DateComponents(day: index - self.start), to: self.montly.date)!
                      newdaily.monthly = montly
                      CoreDataSave()
                      dailyObjectID = newdaily
                      dailyActive = true
                    }
                    
                  } label: {
                    VStack(alignment: .leading, spacing: 1) {
                      Text("\(index - self.start + 1)")
                        .frame(maxWidth: .infinity, alignment: .center)
                      
                      if let daily = dailes.first { DailyMO in
                        calendar.component(.day, from: DailyMO.date) == calendar.component(.day, from: calendar.date(byAdding: DateComponents(day: index - self.start), to: self.montly.date)!)
                      } {
                        Text(daily.text)
                          .font(.system(size: 10, weight: .regular))
                          .lineLimit(nil)
                          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                      } else {
                        Text("")
                          .frame(maxWidth: .infinity, maxHeight: .infinity)
                      }

                    }
                    .frame(height: calgeo.size.height/6)
                    .background(Color.white)
                    .foregroundColor(.black)
                  }
                } else {
                  VStack(alignment: .leading, spacing: 0) {
                    Text("\(index - last - start + 1)")
                      .frame(maxWidth: .infinity, alignment: .center)
                      .padding(.bottom)

                    Spacer().frame(minWidth: 0, maxWidth: .infinity)
                  }
                  .frame(height: calgeo.size.height/6)
                    .background(Color.white)
                    .foregroundColor(.gray)

                }

              }
            } //grid
            .frame(maxHeight: .infinity)
            .background(.gray.opacity(0.2))
            .ignoresSafeArea()
          } //calgeo
          .ignoresSafeArea()

        } //v
      } //geo
      .onAppear{
        if (titleVisible) {
          pageNavi.title = self.montly.page!.title
          pageNavi.pageObjectID = self.montly.page!.objectID
        }
      }
      .onChange(of: titleVisible) { V in
        if V {
          pageNavi.title = self.montly.page!.title
          pageNavi.pageObjectID = self.montly.page!.objectID
        }
      }
      .onChange(of: montly.page!.title) { V in
        print(V)
        pageNavi.title = self.montly.page!.title
        pageNavi.pageObjectID = self.montly.page!.objectID
      }
//      .navigationTitle(title)
    }
}
