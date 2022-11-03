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

  @ObservedObject var note: NoteMO
  
  @State var isPageAdd = false
  @State var isNoteSetting = false
  
  let stack = PersistenceController.shared
  
  var body: some View {
    VStack{
      if note.pages.count == 0 {
        Text("페이지를 추가해주세요.")
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
          .background(Color.customBg)
          .fullScreenCover(isPresented: $isPageAdd) {
            PageAddView(note: note)
          }
          .fullScreenCover(isPresented: $isNoteSetting) {
            NoteSettingView(note: note)
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
                  isNoteSetting.toggle()
                } label: {
                  Image(systemName: "gearshape")
                    .foregroundColor(Color.customIc)
                }
              }
            }
          }//toolbar
      } else if note.style == noteStyle.page.rawValue {
        PageView(note: note, pageIndex: note.lastIndex)
          .foregroundColor(Color.customText)
          .background(Color.customBg)
      } else if note.style == noteStyle.list.rawValue {
        PageListView(note: note)
          .foregroundColor(Color.customText)
          .background(Color.customBg)
      }
    }
  }
}
