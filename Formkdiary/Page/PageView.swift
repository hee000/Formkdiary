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
  @EnvironmentObject var keyboardManager: KeyboardManager

  @ObservedObject var note: NoteMO
//  @State var pageIndex: Int
//  let pages: [PageMO]
  @FetchRequest var pages : FetchedResults<PageMO>
  
  

  @State var pageIndex: Int32
  init(note: NoteMO, pageIndex: Int32) {
    self.note = note
    
    var predicate = NSPredicate(format: "note == %@", note)
    _pages = FetchRequest(entity: PageMO.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \PageMO.index, ascending: true)], predicate: predicate)
    
    _pageIndex = State(wrappedValue: pageIndex)
  }
  
  @State var isNoteSetting = false
  @State var isGrid = false
  
  @State var isPageAdd = false
  
  var body: some View {
    if !pages.isEmpty{
      TabView(selection: $pageIndex) {
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
      .background(Color.customBg)
      .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//      .tab
      
      .onAppear{
        note.lastIndex = pageIndex
        CoreDataSave()
      }
      .onChange(of: pageIndex, perform: { V in
        note.lastIndex = V
        CoreDataSave()
      })
      .onChange(of: note.style, perform: { _ in
        presentationMode.wrappedValue.dismiss()
      })
      .sheet(isPresented: $isGrid, content: {
//        if let pages = note.pages.allObjects.sorted(by: {($0 as! PageMO).index < ($1 as! PageMO).index}) as? [PageMO] {
        PageGridView(note: note, pageIndex: $pageIndex)
          .foregroundColor(Color.customText)
//        }
      })
      
      .fullScreenCover(isPresented: $isNoteSetting) {
        NoteSettingView(note: note, page: pages[pageIndex >= pages.count ? pages.count - 1 : Int(pageIndex)])
      }
      .fullScreenCover(isPresented: $isPageAdd) {
        PageAddView(note: note)
      }
      
      .navigationBarTitle(pages.count > Int(pageIndex) ? pages[Int(pageIndex)].title : pages[pages.count - 1].title)
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarBackButtonHidden(true)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          HStack{
            Button {
              presentationMode.wrappedValue.dismiss()
            } label: {
              Image(systemName: "chevron.left")
                .foregroundColor(Color.customIc)
            }
            if note.style == 1 {
              Button {
                isGrid.toggle()
              } label: {
                Image(systemName: "square.grid.2x2")
                  .foregroundColor(Color.customIc)
              }
            }
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          HStack {
            Button {
              isPageAdd.toggle()
            } label: {
              Image(systemName: "plus")
                .foregroundColor(Color.customIc)
            }
            
            Button {
              isNoteSetting.toggle()
            } label: {
              Image(systemName: "gearshape")
                .foregroundColor(Color.customIc)
            }
          }
        }
      }//toolbar
    } else {
      ProgressView()
        .onAppear{
          if note.style == 0 {
            presentationMode.wrappedValue.dismiss()
          }
        }
    }
    
  }
}


