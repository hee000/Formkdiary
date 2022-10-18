//
//  DailyViewOnPage.swift
//  Formkdiary
//
//  Created by cch on 2022/09/24.
//

import SwiftUI

struct DailyViewOnPage: View {
  @Environment(\.managedObjectContext) private var viewContext
  @EnvironmentObject var pageNavi: PageNavi
  
  @ObservedObject var daily: DailyMO
  let titleVisible: Bool

  init(daily: DailyMO, titleVisible: Bool = false) {
    self.daily = daily
    
    self.titleVisible = titleVisible
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
      .onAppear{
        if (titleVisible) {
          pageNavi.title = self.daily.page!.title
          pageNavi.pageObjectID = self.daily.page!.objectID
        }
      }
      .onChange(of: titleVisible) { V in
        if V {
          pageNavi.title = self.daily.page!.title
          pageNavi.pageObjectID = self.daily.page!.objectID
        }
      }
      
    }
}
