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
  @EnvironmentObject var pageNavi: PageNavi

  @ObservedObject var note: NoteMO
  
  @State var isPageAdd = false
  @State var isNoteSetting = false
  
  @State private var share: CKShare?
  @State private var shareNote: NoteMO?
  @State private var showShareSheet = false
  let stack = PersistenceController.shared
  
  var body: some View {
    GeometryReader { geo in
      VStack{
        if note.pages.count == 0 {
          Text("페이지를 추가해주세요.")
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

        } else if note.isGird {
          if let pages = note.pages.allObjects.sorted(by: {($0 as! PageMO).index < ($1 as! PageMO).index}) as? [PageMO] {
            PageSelectView(note: note, pages: pages)
              .onAppear{
                pageNavi.pageObjectID = nil
              }
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
    .sheet(isPresented: $showShareSheet, content: {
      VStack{
        if let share = share, let note = shareNote {
          CloudSharingView(share: share, container: PersistenceController.shared.ckContainer, note: note)
            .ignoresSafeArea()
        }
      }
      .task {
        guard let shareNote = shareNote else { return }
        self.share = stack.getShare(shareNote)
      }
    })
    
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
          
          if let share = stack.getShare(note), share.participants.count > 1  {
            Button {
              self.share = nil
              shareNote = note
              showShareSheet = true
            } label: {
              Image(systemName: "person.2.fill")
            }
          }
          
          Button {
            print("asdasdda")
            print(pageNavi)
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
