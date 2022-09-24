//
//  NoteView.swift
//  Formkdiary
//
//  Created by cch on 2022/06/23.
//

import SwiftUI
import CoreData


struct NoteView: View {
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.managedObjectContext) private var viewContext
  @EnvironmentObject var pageNavi: PageNavi

  @ObservedObject var note: NoteMO
  
  @State var isPageAdd = false
  @State var isNoteSetting = false
  
  var body: some View {
    GeometryReader { geo in
      VStack{
        if note.pages.count == 0 {
          Text("페이지를 추가해주세요.")
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

        } else if note.isGird {
          if let pages = note.pages.allObjects.sorted(by: {($0 as! PageMO).index < ($1 as! PageMO).index}) as? [PageMO] {
            PageSelectView(note: note, pages: pages)
          }

        } else if !note.isGird {
          if let pages = note.pages.allObjects.sorted(by: {($0 as! PageMO).index < ($1 as! PageMO).index}) as? [PageMO] {
            PageView(note: note, pageIndex: Int(note.lastIndex), pages: pages)
          }
        }
      }
    } //geo
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
            .foregroundColor(.black)
        }
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        HStack {
          Button {
            isPageAdd.toggle()
          } label: {
            Image(systemName: "plus")
              .foregroundColor(.black)
          }
          
          Button {
            print("asdasdda")
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
