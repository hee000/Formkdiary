//
//  PageAddView.swift
//  Formkdiary
//
//  Created by cch on 2022/06/23.
//

import SwiftUI
import CoreData
import Combine

func yearArray() -> [Date] {
  let now = Date()
  let cal = Calendar.current
  var arr: [Date] = []
  
  for i in -10...10 {
    arr.append(cal.date(byAdding: .year, value: i, to: now)!)
  }

  return arr
}


func monthArray() -> [Date] {
  let now = Date()
  let cal = Calendar.current
  var arr: [Date] = []
  
  let year = cal.component(.year, from: now)

  let yearDate1 = cal.date(from: DateComponents(year: year))!
  let yearDate2 = cal.date(byAdding: .day, value: 1, to: yearDate1)!
  
  for i in 0...11 {
    arr.append(cal.date(byAdding: .month, value: i, to: yearDate2)!)
  }
  
  return arr
}

struct PageAddView: View {
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.managedObjectContext) private var viewContext
  
  @ObservedObject var note: NoteMO
  @StateObject var model = PageAddModel()
  
  func pageAddViewExit() {
    presentationMode.wrappedValue.dismiss()
  }
  
  var body: some View {
    NavigationView{
      VStack{
        HStack{
          Button{
            model.setCategory(0)
          } label: {
            Text("Monthly")
          }
          .frame(minWidth: 0, maxWidth: .infinity)
          
          Button{
            model.setCategory(1)
          } label: {
            Text("Weekly")
          }
          .frame(minWidth: 0, maxWidth: .infinity)
          
          Button{
            model.setCategory(2)
          } label: {
            Text("Daily")
          }
          .frame(minWidth: 0, maxWidth: .infinity)
          
          Button{
            model.setCategory(3)
          } label: {
            Text("Memo")
          }
          .frame(minWidth: 0, maxWidth: .infinity)
          
        } //h
        .frame(height: 50)
        .foregroundColor(Color.customText)
//          ScrollView{
        ZStack{
          PageAddMonthly(note: note)
            .opacity(model.category[0])
          PageAddWeekly(note: note)
            .opacity(model.category[1])
          PageAddDaily(note: note)
            .opacity(model.category[2])
          PageAddMemo(note: note)
            .opacity(model.category[3])
        }
          
      } // v
      .background(Color.customBg)
      .foregroundColor(Color.customText)
//        }//scroll
      .navigationTitle("페이지 만들기")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            presentationMode.wrappedValue.dismiss()
          } label: {
            Image(systemName: "xmark")
              .foregroundColor(Color.customIc)
          }
        }
      }//tool
    }//navi
    .task {
      model.pageAddViewExit = pageAddViewExit
    }
    .environmentObject(model)
  }
}
