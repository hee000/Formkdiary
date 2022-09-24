//
//  PageView.swift
//  Formkdiary
//
//  Created by cch on 2022/09/14.
//

import SwiftUI
import CoreData
import UIKit

struct PageView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.presentationMode) var presentationMode
  @EnvironmentObject var pageNavi: PageNavi

  @ObservedObject var note: NoteMO
  @State var pageIndex: Int
  let pages: [PageMO]
  
  @State var isNoteSetting = false
  
  var body: some View {
    if !pages.isEmpty{
      TabView(selection: $pageIndex) {
        ForEach(Array(pages.enumerated()), id: \.offset) { idx, page in
          if let monthly = page.monthly {
            MonthlyDefaultView(_monthly: monthly, titleVisible: pageIndex == idx)
              .tag(idx)
          } else if let weekly = page.weekly {
            WeeklyDefaultView(weekly: weekly, titleVisible: pageIndex == idx)
              .tag(idx)
          } else if let daily = page.daily {
            DailyViewOnPage(daily: daily, titleVisible: pageIndex == idx)
              .tag(idx)
          } else if let memo = page.memo {
            MemoView(memo: memo, titleVisible: pageIndex == idx)
              .tag(idx)
          }
        }
      } //tab
      .tabViewStyle(PageTabViewStyle())
      
      .onAppear{
        note.lastIndex = Int32(pageIndex)
        CoreDataSave()
      }
      .onChange(of: pageIndex, perform: { V in
        note.lastIndex = Int32(V)
        CoreDataSave()
      })
      .onChange(of: note.isGird, perform: { _ in
        presentationMode.wrappedValue.dismiss()
      })
      
      .fullScreenCover(isPresented: $isNoteSetting) {
        NoteSettingView(id: note.objectID, in: viewContext, pgid: pageNavi.pageObjectID)
      }
      
      .navigationBarTitle(pageNavi.title)
      .navigationBarBackButtonHidden(true)
      .toolbar {
        if note.isGird {
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
              isNoteSetting.toggle()
            } label: {
              Image(systemName: "gearshape")
                .foregroundColor(.black)
            }
          }
        }
      }//toolbar
    }
    
  }
}
