//
//  MemoView.swift
//  Formkdiary
//
//  Created by cch on 2022/09/24.
//

import SwiftUI

struct MemoView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @EnvironmentObject var pageNavi: PageNavi
  
  @ObservedObject var memo: MemoMO
  let titleVisible: Bool

  init(memo: MemoMO, titleVisible: Bool = false) {
    self.memo = memo
    
    self.titleVisible = titleVisible
  }
  
    var body: some View {
      GeometryReader { geo in
        TextEditor(text: $memo.text)
          .frame(maxWidth:.infinity)
          .frame(maxHeight:.infinity)
          .padding()
      }
      .onChange(of: memo.text, perform: { newValue in
//        print(newValue)
        CoreDataSave()
      })
      .onAppear{
        if (titleVisible) {
          pageNavi.title = self.memo.page!.title
          pageNavi.pageObjectID = self.memo.page!.objectID
        }
      }
      .onChange(of: titleVisible) { V in
        if V {
          pageNavi.title = self.memo.page!.title
          pageNavi.pageObjectID = self.memo.page!.objectID
        }
      }
    }
}

