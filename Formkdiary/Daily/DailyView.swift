//
//  DailyView.swift
//  Formkdiary
//
//  Created by cch on 2022/07/01.
//

import SwiftUI
import CoreData

struct DailyView: View {
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.managedObjectContext) private var viewContext
  
  @ObservedObject var daily: DailyMO
  
  let title: String
  
  

  init(id objectID: NSManagedObjectID, in context: NSManagedObjectContext) {
    let calendar = Calendar.current
//    var dateComponent: DateComponents
      if let daily = try? context.existingObject(with: objectID) as? DailyMO {
        title = "\(calendar.component(.day, from: daily.date))일"
        self.daily = daily
          
      } else {
          // if there is no object with that id, create new one
        let daily = DailyMO(context: context)
        title = "\(calendar.component(.day, from: daily.date))일"
        self.daily = daily
        try? context.save()
      }
  }
  
    var body: some View {
      GeometryReader { geo in
        TextEditor(text: $daily.text)
          .frame(maxWidth:.infinity)
          .frame(maxHeight:.infinity)
          .padding(3)
      }
      .onChange(of: daily.text, perform: { newValue in
        print(newValue)
        CoreDataSave()
      })
      
      .navigationTitle(title)
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
