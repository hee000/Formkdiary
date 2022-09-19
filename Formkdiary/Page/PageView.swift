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

  @ObservedObject var note: NoteMO
  @State var pageIndex: Int
  let pages: [PageMO]
  
  @State var isNoteSetting = false
  
  var body: some View {
    if !pages.isEmpty{
      TabView(selection: $pageIndex) {
        ForEach(Array(zip(pages.indices, pages)), id: \.1) { idx, page in
          if let monthly = page.monthly {
            MonthlyDefaultView(id: monthly.objectID, in: viewContext)
              .tag(idx)
          }
          else if let weeekly = page.weekly {
            WeeklyDefaultView(id: weeekly.objectID, in: viewContext)
              .tag(idx)
          }

        } //for
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
        NoteSettingView(id: note.objectID, in: viewContext)
      }
      
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
