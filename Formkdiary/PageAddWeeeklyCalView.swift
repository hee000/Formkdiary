//
//  PageAddWeeeklyCalView.swift
//  Formkdiary
//
//  Created by cch on 2022/07/01.
//

import SwiftUI

struct PageAddWeeeklyCalView: View {
  @Binding var weekIndex: Int

  let week = ["일", "월", "화", "수", "목", "금", "토"]
  var before: Int
  var start: Int
  var last: Int
  let columns = [
      GridItem(.flexible(), spacing: 1),
      GridItem(.flexible(), spacing: 1),
      GridItem(.flexible(), spacing: 1),
      GridItem(.flexible(), spacing: 1),
      GridItem(.flexible(), spacing: 1),
      GridItem(.flexible(), spacing: 1),
      GridItem(.flexible(), spacing: 1)
      ]
  var cal = Calendar.current
  let height = (UIScreen.main.bounds.size.height / 15)
  
  @State var selected = Array(repeating: false, count: 42)

  init(weekIndex: Binding<Int>) {
    self._weekIndex = weekIndex
    let calendar = Calendar.current
    var dateComponent: DateComponents
    dateComponent = calendar.dateComponents([.year, .month], from: Date())
    let month = calendar.date(from: dateComponent)!
    start = calendar.component(.weekday, from: month)
    last = calendar.range(of: .day, in: .month, for: month)?.last ?? 30
    let beforeMonthLastDay = calendar.date(byAdding: DateComponents(day: -1), to: month) ?? Date()
    before = calendar.component(.day, from: beforeMonthLastDay)
  }
  
    var body: some View {
      GeometryReader { geo in
        VStack{
          HStack {
            ForEach(0..<7){ index in
              Text(week[index])
                .frame(minWidth: 0, maxWidth: .infinity)
            }
          }
          
//          Divider()
          
          GeometryReader { calgeo in
            LazyVGrid(columns: self.columns, spacing: 1){
              ForEach(1..<43, id:\.self) { index in
                if index < self.start {
                  VStack(alignment: .leading, spacing: 0) {
                    Text("\(self.before - self.start + 1 + index)")
  //                    .padding()
                  }
                  .frame(height: calgeo.size.height/6)
                  .background(Color.white)
                  .foregroundColor(.gray)
                } else if (index - self.start) < self.last {
                  Button{
                    if (index % 7 == 1) || (index % 7 == 2) {
                      selected = selected.map{$0 && false}
                      weekIndex = index - self.start + 1
                      for i in 0..<7 {
                        if selected.count > index + i {
                          selected[index + i] = true
                        }
                      }
                    }
                    let calendar = Calendar.current
                    var dateComponent = DateComponents(year: 2022, month: 7, day: (index - self.start + 1))
  //                  dateComponent.year = 2022
  //                  dateComponent.year = 7
  //                  dateComponent.day = index - self.start + 1
                    
                    let month = calendar.date(from: dateComponent)!
                    
                    print(calendar.component(.weekOfMonth, from: month))
                  } label:{
                    VStack(alignment: .leading, spacing: 0) {
                      Text("\(index - self.start + 1)")
  //                      .padding()
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: calgeo.size.height/6)
//                    .background(selected[index] ? Color.gray : Color.white)
                    .overlay(selected[index] ? Circle().fill(Color.black.opacity(0.4)) : nil)
                    .foregroundColor(.black)
                  }
                } else {
                  VStack(alignment: .leading, spacing: 0) {
                    Text("\(index - last - start + 1)")
  //                    .padding()
                  }
                  .frame(height: calgeo.size.height/6)
                  .background(Color.white)
                  .foregroundColor(.gray)

                }
              } //for
            } //grid
          } // calgeo
        }//v

      }//geo
    }
}

