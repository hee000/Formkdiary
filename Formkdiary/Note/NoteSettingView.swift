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
  @EnvironmentObject var pageNavi: PageNavi

  
  @ObservedObject var note: NoteMO
  
  @ObservedObject var page: PageMO
  
  
  @State var column: Int
  
  init(id objectID: NSManagedObjectID, in context: NSManagedObjectContext, pgid pageObjectID: NSManagedObjectID? = nil) {
    if let note = try? context.existingObject(with: objectID) as? NoteMO {
        self.note = note
        _column = State(initialValue: Int(note.column))
    } else {
        // if there is no object with that id, create new one
      let note = NoteMO(context: context)
        self.note = note
        _column = State(initialValue: Int(note.column))
        try? context.save()
    }
    
    if let pid = pageObjectID, let page = try? context.existingObject(with: pid) as? PageMO {
      self.page = page
//      print(page)
    } else {
      self.page = PageMO(context: context)
    }
    
//    print(_page)

  }
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading) {
          Toggle(isOn: $note.isGird) {
            Text("페이지 그리드 보기")
              .bold()
          }
          .padding(.top)
          .padding(.top)
          .toggleStyle(SwitchToggleStyle())
          .tint(.gray)
          .onChange(of: note.isGird) { _ in
            CoreDataSave()
          }
          
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
            
            Toggle(isOn: $note.titleVisible) {
              Text("페이지 이름 보기")
                .bold()
            }
            .toggleStyle(SwitchToggleStyle())
            .tint(.gray)
            .onChange(of: note.titleVisible) { _ in
              CoreDataSave()
            }
            
            Divider()
              .padding([.top, .bottom])
          }

          
          if page.note != nil {
            Text("페이지 설정")
              .bold()
              .font(.title)
              .padding(.bottom)
            
            Text("이름")
              .bold()
//              .padding(.trailing)
            
            TextField("제목", text: $page.title)
              .onChange(of: page.title) { newValue in
                pageNavi.title = newValue
                CoreDataSave()
              }
              .padding()
              .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.7), lineWidth: 1))
              .padding(.bottom)
            
            
            if let weekly = page.weekly {
              Text("스타일")
                .bold()
              
              HStack{
                Button{
                } label: {
                  VStack{
                    VStack{
                      HStack{
                        Rectangle()
                          .fill(Color.gray)
                          .cornerRadius(5)
                        Rectangle()
                          .fill(Color.gray)
                          .cornerRadius(5)
                      }
                      HStack{
                        Rectangle()
                          .fill(Color.gray)
                          .cornerRadius(5)
                        Rectangle()
                          .fill(Color.clear)
                          .cornerRadius(5)
                      }
                    }
                    .padding([.leading, .trailing])
                    .padding([.leading, .trailing])
                    Text("두줄보기")
                  }
                }
                .frame(height: 60)
                
                Button{
//                  monthlyStyle = "twoColumnStyle"
                } label: {
                  VStack{
                    VStack{
                      Rectangle()
                        .fill(Color.gray)
                        .cornerRadius(5)
                      Rectangle()
                        .fill(Color.gray)
                        .cornerRadius(5)
                      Rectangle()
                        .fill(Color.gray)
                        .cornerRadius(5)
                    }
                      .padding([.leading, .trailing])
                      .padding([.leading, .trailing])
                    Text("한줄보기")
                  }
                }
              }
              .frame(height: 60)
              .frame(width:2*UIScreen.main.bounds.size.width/3)
              
            }
          }
          
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
