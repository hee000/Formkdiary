//
//  DailyTest.swift
//  Formkdiary
//
//  Created by cch on 2022/09/20.
//

import SwiftUI

struct DailyViewWithoutPage: View {
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.managedObjectContext) private var viewContext
  
  @AppStorage("StartMonday") var startMonday: Bool = UserDefaults.standard.bool(forKey: "StartMonday")
  @ObservedObject var daily: DailyMO
  
  var calendar: Calendar = CalendarModel.shared.calendar

  init(daily: DailyMO) {
    self.daily = daily
    
//    self.calendar =  Calendar(identifier: .gregorian)
//    if UserDefaults.standard.bool(forKey: "StartMonday") {
//      self.calendar.firstWeekday = 2
//    } else {
//      self.calendar.firstWeekday = 1
//    }
  }
  
    var body: some View {
      GeometryReader { geo in
        TextEditor(text: $daily.text)
          .frame(maxWidth:.infinity, maxHeight:.infinity)
          .padding()
      }
      .onChange(of: daily.text, perform: { newValue in
//        print(newValue)
        daily.editedAt = Date()
        CoreDataSave()
      })
      .onDisappear{
        if daily.text == "" {
          viewContext.delete(daily)
          CoreDataSave()
        }
      }
      
      .navigationTitle("\(calendar.component(.day, from: daily.date))일")
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
