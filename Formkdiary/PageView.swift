//
//  PageView.swift
//  Formkdiary
//
//  Created by cch on 2022/09/14.
//

import SwiftUI

struct PageView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.presentationMode) var presentationMode

  @State var pageIndex = 0
  let pages: [PageMO]
  
  var body: some View {
    if !pages.isEmpty{
      TabView(selection: $pageIndex) {
        ForEach(Array(zip(pages.indices, pages)), id: \.1) { idx, page in
          if let monthly = page.monthly {
            MonthlyDefaultView(id: monthly.objectID, in: viewContext)
              .tag(idx)
          }
          else if let weeekly = page.weekly {
            WeeeklyDefaultView(id: weeekly.objectID, in: viewContext)
              .tag(idx)
          }

        } //for
      } //tab
      .tabViewStyle(PageTabViewStyle())
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
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            
          } label: {
            Image(systemName: "gear")
              .foregroundColor(.black)
          }
        }
      }//toolbar
    }
    
  }
}
