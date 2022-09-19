//
//  MainView.swift
//  Formkdiary
//
//  Created by cch on 2022/06/23.
//

import SwiftUI

struct MainView: View {
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(
      sortDescriptors: [
        SortDescriptor(\.createdAt)
      ],
      animation: .default)
  private var notes: FetchedResults<NoteMO>
  
  @State var noteAdd = false
  
  @State var delete = false
  @State var isSlideMenu = false
  
  
    var body: some View {
      NavigationView{
        ZStack{
          ScrollView {
            if notes.isEmpty {
              Text("새 노트를 추가해주세요")
            } else {
              LazyVStack(spacing: 10) {
                ForEach(notes) { note in
                  HStack{
                    NavigationLink(destination: NoteView(note: note)) {
                      Text(note.title)
                        .foregroundColor( .black)
                        .onAppear{
                          print(note.title, note.pages)
                        }
                    }
                    
                    if delete {
                      Button{
                        viewContext.delete(note)
                        CoreDataSave()
                      } label: {
                        Image(systemName: "xmark")
                          .foregroundColor(.red)
                      }
                    }
                  }
                } //for
              }
              
            } // if

          } //scoll
          
          SideMenu(width: 270,
                   isOpen: self.isSlideMenu,
                   menuClose: self.openMenu,
                   noteDelte: self.noteDelete)
        }//z

        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button {
//              delete.toggle()
              openMenu()
              print("툴바")
            } label: {
              Image(systemName: "line.horizontal.3")
                .foregroundColor(.black)
            }
          }
          
          
          ToolbarItem(placement: .navigationBarTrailing) {
            HStack{
              if delete {
                Button {
                  noteDelete()
                } label: {
                  Image(systemName: "xmark")
                    .foregroundColor(.black)
                }
              }
              
              Button {
                noteAdd.toggle()
              } label: {
                Image(systemName: "plus")
                  .foregroundColor(.black)
              }
            }
            
          }
          
        } //toolbar
      }//navi
      .navigationViewStyle(StackNavigationViewStyle())
      .fullScreenCover(isPresented: $noteAdd) {
        NoteAddView()
      }
    }
  
  func noteDelete() {
//    withAnimation {
      self.delete.toggle()
//    }
  }
  
  func openMenu() {
    withAnimation {
      self.isSlideMenu.toggle()
    }
  }
}



struct MenuContent: View {
  let menuClose: () -> Void
  let noteDelte: () -> Void
  
  @AppStorage("StartMonday") var startMonday: Bool = UserDefaults.standard.bool(forKey: "StartMonday")
  @State var isDaySetting = false
  
    var body: some View {
      VStack{
        List{
          Button{
            noteDelte()
            menuClose()
          } label: {
            Text("노트 지우기")
          }
  //        .listRowBackground(Color.pink)
//          Text("시작 요일 설정")
          
//
          Button{
            isDaySetting.toggle()
          } label: {
            Text("한 주의 시작")
          }
          .onChange(of: isDaySetting, perform: { newValue in
            print(newValue, "바뀜")
          })
//
          .confirmationDialog("현재 시작 요일: \(!startMonday ? "일요일" : "월요일")", isPresented: $isDaySetting, titleVisibility: .visible) {
            Button("일요일", role: .destructive) {
              startMonday = false
            }
            
            Button("월요일") {
              startMonday = true
            }

            Button("취소", role: .cancel) { }
          }
          
          
        }
        .onAppear {
            // Set the default to clear
            UITableView.appearance().backgroundColor = .clear
        }
        Text("For mk")
      }

    }
}

struct SideMenu: View {
    let width: CGFloat
    let isOpen: Bool
    let menuClose: () -> Void
    let noteDelte: () -> Void
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                EmptyView()
            }
            .background(Color.black.opacity(0.3))
            .opacity(self.isOpen ? 1.0 : 0.0)
            .onTapGesture {
                self.menuClose()
            }
            
            HStack {
                MenuContent(menuClose: menuClose, noteDelte: noteDelte)
                    .frame(width: self.width)
                    .background(Color.white)
                    .offset(x: self.isOpen ? 0 : -self.width)
                Spacer()
            }
        }
    }
}
