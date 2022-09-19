//
//  SettingView.swift
//  Formkdiary
//
//  Created by cch on 2022/09/17.
//

import SwiftUI
import CoreData

let SettingColumn = (UserDefaults.standard.integer(forKey: "Setting-Column") != 0) ? UserDefaults.standard.integer(forKey: "Setting-Column") : 2

let SettingColumnRange = [2, 3, 4]

struct NoteSettingView: View {
  @Environment(\.presentationMode) var presentationMode
  
  @ObservedObject var note: NoteMO
  
  @State var column: Int
  
  init(id objectID: NSManagedObjectID, in context: NSManagedObjectContext) {
    if let note = try? context.existingObject(with: objectID) as? NoteMO {
        self.note = note
        _column = State(initialValue: Int(note.column))
    } else {
        // if there is no object with that id, create new one
      var note = NoteMO(context: context)
        self.note = note
        _column = State(initialValue: Int(note.column))
        try? context.save()
    }
  }
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading) {
          Toggle(isOn: $note.isGird) {
            Text("페이지 그리드 보기")
              .bold()
          }
            .toggleStyle(SwitchToggleStyle())
            .tint(.gray)
            .onChange(of: note.isGird) { _ in
              withAnimation {
                CoreDataSave()
              }
//              CoreDataSave()
            }
            .padding(.top)
            .padding(.top)
          
          Divider()
            .padding([.top, .bottom])
          
          if note.isGird {
            HStack {
              Text("페이지 개수")
                .bold()
                .padding(.trailing)
              Picker("column picker", selection: $column) {
                ForEach(SettingColumnRange, id:\.self) { column in
                  Text("\(column)")
                }
              }
              .pickerStyle(SegmentedPickerStyle())
            }
            
            Divider()
              .padding([.top, .bottom])
          }
  
          
          Text("기타 설정 등")
          
        }
        .padding([.leading, .trailing])
        .padding([.leading, .trailing])
      } //scroll
      .onChange(of: column, perform: { newValue in
        note.column = Int16(newValue)
        CoreDataSave()
      })
      .navigationTitle("노트 설정")
      .navigationBarTitleDisplayMode(.inline)
//      .navigationBarBackButtonHidden(true)
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
