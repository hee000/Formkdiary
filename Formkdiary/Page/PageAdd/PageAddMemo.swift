//
//  PageAddMemo.swift
//  Formkdiary
//
//  Created by hee on 2022/11/02.
//

import SwiftUI

struct PageAddMemo: View {
  @EnvironmentObject var model: PageAddModel
  @ObservedObject var note: NoteMO
  
  var body: some View {
    VStack{
      Text("Memo")
        .bold()

      Text("메모 이름 설정")

      VStack{
        TextField("제목 없음", text: $model.memoNameString)
          .disableAutocorrection(true)
          .textCase(.none)
        Divider()
      }.frame(width: UIScreen.main.bounds.size.width/3*2)

      Spacer()

      Button{
        model.savePage(note: note)
      } label: {
        Text("만들기")
          .foregroundColor(Color.customText)
          .frame(width: UIScreen.main.bounds.size.width/4, height: UIScreen.main.bounds.size.height/20)
          .background(Color.customTextLight)
          .cornerRadius(5)
      }
    }
  }
}
