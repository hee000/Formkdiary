//
//  NoteView.swift
//  Formkdiary
//
//  Created by cch on 2022/06/23.
//

import CloudKit
import SwiftUI
import CoreData


struct NoteView: View {
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.managedObjectContext) private var viewContext
  @EnvironmentObject var keyboardManager: KeyboardManager
  @EnvironmentObject var pageNavi: PageNavi
  @EnvironmentObject var searchNavigator: SearchNavigator

  @ObservedObject var note: NoteMO
  
  @State var isPageAdd = false
  @State var isNoteSetting = false
  
  let stack = PersistenceController.shared
  
  var body: some View {
//    GeometryReader { geo in
      VStack{
        if note.pages.count == 0 {
          Text("페이지를 추가해주세요.")
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color.customBg)
        } else if note.style == noteStyle.page.rawValue {
          PageView(note: note)
            .foregroundColor(Color.customText)
            .background(Color.customBg)
            .onAppear{
              if searchNavigator.isPage {
                guard let page = searchNavigator.page else { return }
                note.lastIndex = page.index
                searchNavigator.isPage = false
              }
            }
//            .edgesIgnoringSafeArea(.bottom)
//            .edgesIgnoringSafeArea(.top)
        } else if note.style == noteStyle.list.rawValue {
          PageListView(note: note)
            .foregroundColor(Color.customText)
            .background(Color.customBg)
            .onAppear{
              pageNavi.pageObjectID = nil
            }
            
        }
      }
//      .ignoresSafeArea()
      
//    } //geo
//    .border(.red)
//    .fixedSize()
//    .frame(maxWidth: .infinity, maxHeight: .infinity)
    
//    .fixedSize(horizontal: false, vertical: true)
    .fullScreenCover(isPresented: $isPageAdd) {
      PageAddView(id: note.objectID, in: viewContext)
    }
    .fullScreenCover(isPresented: $isNoteSetting) {
      NoteSettingView(id: note.objectID, in: viewContext, pgid: pageNavi.pageObjectID)
    }
    
    .navigationTitle(note.title)
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          presentationMode.wrappedValue.dismiss()
        } label: {
          Image(systemName: "chevron.left")
            .foregroundColor(Color.customIc)
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
            print("asdasdda")
            print(pageNavi)
            isNoteSetting.toggle()
          } label: {
            Image(systemName: "gearshape")
              .foregroundColor(Color.customIc)
          }
        }
      }
    }//toolbar
  }
}
