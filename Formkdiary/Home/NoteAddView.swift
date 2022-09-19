//
//  NoteAddView.swift
//  Formkdiary
//
//  Created by cch on 2022/06/23.
//

import SwiftUI
import Combine

struct NoteAddView: View {
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.managedObjectContext) private var viewContext
  
  @State var title = ""
  
  let textLimit = 35
  
  func limitText(_ upper: Int) {
      if title.count > upper {
        title = String(title.prefix(upper))
      }
  }

    var body: some View {
      NavigationView{
        VStack{
          TextField("노트 제목을 입력해주세요.", text: $title)
            .frame(width: UIScreen.main.bounds.size.width/3*2)
            .disableAutocorrection(true)
            .textCase(.none)
          Divider()
            .frame(width: UIScreen.main.bounds.size.width/3*2)
            .padding(.bottom)
            .onReceive(Just(title)) { _ in limitText(textLimit) }

          Button{
            if title != "" {
              let newNote = NoteMO(context: viewContext)
              newNote.title = self.title
              CoreDataSave()
              presentationMode.wrappedValue.dismiss()
            }
          } label: {
            Text("만들기")
              .foregroundColor(.white)
              .frame(width: UIScreen.main.bounds.size.width/4, height: UIScreen.main.bounds.size.height/20)
              .background(.black)
              .cornerRadius(5)
          }
        } // v
        .navigationTitle("노트 만들기")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button {
              presentationMode.wrappedValue.dismiss()
            } label: {
              Image(systemName: "xmark")
                .foregroundColor(.black)
            }
          }
        }//toolbar
      } //navi
    }
}

struct NoteAddView_Previews: PreviewProvider {
    static var previews: some View {
        NoteAddView()
    }
}
