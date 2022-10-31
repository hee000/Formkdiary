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
          Spacer()
          Text("노트 이름을 입력해주세요.")
          Spacer()
          
          TextField("NOTE", text: $title)
            .multilineTextAlignment(.center)
            .frame(width: UIScreen.main.bounds.size.width/3*2, alignment: .center)
            .disableAutocorrection(true)
            .foregroundColor(Color.customText)
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
            Text("Create")
              .foregroundColor(Color.customText)
              .frame(width: UIScreen.main.bounds.size.width/4, height: UIScreen.main.bounds.size.height/20)
              .background(Color.customTextLight)
              .cornerRadius(5)
          }
          Spacer()
          Spacer()
        } // v
        .frame(maxWidth: .infinity)
        .background(Color.customBg)
        .navigationTitle("노트 만들기")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button {
              presentationMode.wrappedValue.dismiss()
            } label: {
              Image(systemName: "xmark")
                .foregroundColor(Color.customIc)
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
