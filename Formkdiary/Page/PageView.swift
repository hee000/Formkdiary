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
  @EnvironmentObject var keyboardManager: KeyboardManager
  @EnvironmentObject var searchNavigator: SearchNavigator

  @ObservedObject var note: NoteMO
//  @State var pageIndex: Int
//  let pages: [PageMO]
  @FetchRequest var pages : FetchedResults<PageMO>

  init(note: NoteMO) {
    self.note = note
    
    var predicate = NSPredicate(format: "note == %@", note)
    _pages = FetchRequest(entity: PageMO.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \PageMO.index, ascending: true)], predicate: predicate)
  }
  
  @State var isNoteSetting = false
  @State var isGrid = false
  
  var body: some View {
    if !pages.isEmpty{
      TabView(selection: $note.lastIndex) {
        ForEach(Array(pages.enumerated()), id: \.offset) { idxs, page in
          let idx = Int32(idxs)
          if let monthly = page.monthly {
            MonthlyDefaultView(monthly: monthly, titleVisible: note.lastIndex == idx)
              .tag(idx)
          } else if let weekly = page.weekly {
            WeeklyDefaultView(weekly: weekly, titleVisible: note.lastIndex == idx)
              .tag(idx)
          } else if let daily = page.daily {
            DailyViewOnPage(daily: daily, titleVisible: note.lastIndex == idx)
              .tag(idx)
          } else if let memo = page.memo {
            MemoView(memo: memo, titleVisible: note.lastIndex == idx)
              .tag(idx)
          }
        }
        .background(Color.customBg)
        
      } //tab
      .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//      .tab
      
      .onAppear{
        CoreDataSave()
      }
      .onChange(of: note.lastIndex, perform: { V in
//        note.lastIndex = Int32(V)
        CoreDataSave()
      })
      .onChange(of: note.style, perform: { _ in
        presentationMode.wrappedValue.dismiss()
      })
      .onChange(of: searchNavigator.isPage, perform: { V in
        if let page = searchNavigator.page, V {
          note.lastIndex = page.index
          searchNavigator.isPage = false
        }
      })
      .sheet(isPresented: $isGrid, content: {
        if let pages = note.pages.allObjects.sorted(by: {($0 as! PageMO).index < ($1 as! PageMO).index}) as? [PageMO] {
//          NavigationView{
//            PageSelectView(note: note, pages: pages)
          TSET(note: note, pages: pages)
        }
      })
      
      .fullScreenCover(isPresented: $isNoteSetting) {
        NoteSettingView(id: note.objectID, in: viewContext, pgid: pageNavi.pageObjectID)
      }
      
      .navigationBarTitle(pages.count > Int(note.lastIndex) ? pages[Int(note.lastIndex)].title : pages[pages.count - 1].title)
      .navigationBarBackButtonHidden(true)
      .toolbar {
        if note.style != noteStyle.page.rawValue {
          ToolbarItem(placement: .navigationBarLeading) {
            Button {
              presentationMode.wrappedValue.dismiss()
            } label: {
              Image(systemName: "chevron.left")
                .foregroundColor(Color.customIc)
            }
          }

          ToolbarItem(placement: .navigationBarTrailing) {
            Button {
              isNoteSetting.toggle()
            } label: {
              Image(systemName: "gearshape")
                .foregroundColor(Color.customIc)
            }
          }
        } else {
          ToolbarItem(placement: .navigationBarLeading) {
              Button {
                isGrid.toggle()
              } label: {
                Image(systemName: "square.grid.2x2")
                  .foregroundColor(Color.customIc)
              }
          }
        }
      }//toolbar
      
    }
    
  }
}
