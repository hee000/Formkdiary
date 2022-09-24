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
  
  var calendar: Calendar

  init(daily: DailyMO) {
    self.daily = daily
    
    self.calendar =  Calendar(identifier: .gregorian)
    if UserDefaults.standard.bool(forKey: "StartMonday") {
      self.calendar.firstWeekday = 2
    } else {
      self.calendar.firstWeekday = 1
    }
  }
  
    var body: some View {
      GeometryReader { geo in
        TextEditor(text: $daily.text)
          .frame(maxWidth:.infinity)
          .frame(maxHeight:.infinity)
          .padding()
      }
      .onChange(of: daily.text, perform: { newValue in
        print(newValue)
        CoreDataSave()
      })
      
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
