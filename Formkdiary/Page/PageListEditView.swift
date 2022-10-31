//
//  PageListEditView.swift
//  Formkdiary
//
//  Created by hee on 2022/10/22.
//

import SwiftUI

struct PageListEditView: View {
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.managedObjectContext) private var viewContext

  @ObservedObject var note: NoteMO
  @State var pages: [PageMO] = []
  @State var editMode: Bool = true
  
  func move(from source: IndexSet, to destination: Int) {
    pages.move(fromOffsets: source, toOffset: destination)
  }
  
//  func move(from source: IndexSet, to destination: Int) {
//    var to = destination
//    guard let from = source.first else { return }
//    if from < to {
//      to -= 1
//    }
//
//    pages[to].index = Int32(from)
//    pages[from].index = Int32(to)
//  }
  
    var body: some View {
      List {
        ForEach(Array(pages.enumerated()), id:\.element) { index, page in
          HStack{
            Rectangle()
              .frame(width: 20, height: 1)
            
            Text(page.title)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
          .listRowSeparator(.hidden)
          .listRowBackground(Color.customBg)
        }
        .onMove(perform: move)
      }
      .foregroundColor(Color.customText)
      .background(Color.customBg)
      .listStyle(.plain)
      .navigationTitle("페이지 순서 변경")
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarBackButtonHidden(true)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            presentationMode.wrappedValue.dismiss()
          } label: {
//            Image(systemName: "chevron.left")
//              .foregroundColor(.black)
            Text("취소")
              .foregroundColor(Color.customText)
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            for (index, page) in pages.enumerated() {
              page.index = Int32(index)
            }
            
            CoreDataSave()
            
            presentationMode.wrappedValue.dismiss()
          } label: {
            Text("완료")
              .foregroundColor(Color.customText)
          }
        }
      }//toolbar

      .environment(\.editMode, .constant(self.editMode ? EditMode.active : EditMode.inactive))
      
      .task {
        pages = note.pages.allObjects.sorted(by: {($0 as! PageMO).index < ($1 as! PageMO).index}) as! [PageMO]
//        pages.append(contentsOf: note.pages.toArray())
      }
    }
}
