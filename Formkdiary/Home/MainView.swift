//
//  MainView.swift
//  Formkdiary
//
//  Created by cch on 2022/06/23.
//

import SwiftUI
import Combine
import CloudKit
import CoreData

struct MainView: View {
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(
      sortDescriptors: [
        SortDescriptor(\.createdAt)
      ],
      animation: .default)
  private var notes: FetchedResults<NoteMO>
  
  @State var noteAdd = false
  
  @State var isSlideMenu = false
  
  @State var isDelete = false
  @State var isRename = false
  
  @State var index = 0
  @State var renameString = ""
  @State var isDiaryExport = false
  
  @State private var share: CKShare?
  @State private var shareNote: NoteMO?
  @State private var showShareSheet = false
  
  let stack = PersistenceController.shared
  
  func limitText(_ upper: Int) {
      if renameString.count > upper {
        renameString = String(renameString.prefix(upper))
      }
  }
  
  private func createShare(_ note: NoteMO) async {
    do {
      let (_, share, _) = try await stack.persistentContainer.share([note], to: nil)
      share[CKShare.SystemFieldKey.title] = note.title
      self.share = share
    } catch {
      print("Failed to create share")
    }
  }
  
  
  
  var body: some View {
    NavigationView{
      ZStack{
        List{
          ForEach(Array(notes.enumerated()), id:\.element) { index, note in
            ZStack{
              NavigationLink(destination: NoteView(note: note)) {}.opacity(0)
                .buttonStyle(PlainButtonStyle())
              HStack{
                if let share = stack.getShare(note), share.participants.count > 1 {
                  Image(systemName: "person.2.fill")
                }
                Text(note.title)
                  .lineLimit(1)
              }
              .frame(height: 8)
            }
            .listRowSeparator(.hidden)
            .contextMenu {
              Button {
                self.index = index
                withAnimation{
                  isDelete.toggle()
                }
                print("삭제")
              } label: {
                Label("Delete", systemImage: "trash.fill")
              }
              .tint(.red)


              Button {
                self.index = index
                self.renameString = note.title
                
                withAnimation{
                  isRename.toggle()
                }
                print("리네임")
              } label: {
                Label("Rename", systemImage: "pencil")
              }
              
              Button {
                share = nil
                shareNote = note
                showShareSheet = true
              } label: {
                Text("공유")
              }
            }
          } //for
        } //list
        .listStyle(.plain)
        .padding([.leading, .trailing])
        .background(SharingViewController(isPresenting: $isDiaryExport) {
          let text = exportDiary().text()
          
          let tempDir = FileManager.default.temporaryDirectory
          let strFileName = exportDiary().textFileName()
          let tempStrPath = tempDir.appendingPathComponent(strFileName)
          
          try? text.write(to: tempStrPath, atomically: true, encoding: String.Encoding.utf8)

          
          let av = UIActivityViewController(activityItems: [tempStrPath],  applicationActivities: nil)
            
            // For iPad
            if UIDevice.current.userInterfaceIdiom == .pad {
               av.popoverPresentationController?.sourceView = UIView()
            }

           av.completionWithItemsHandler = { _, _, _, _ in
             isDiaryExport = false // required for re-open !!!
              }
              return av
          })

        
        SideMenu(width: UIScreen.main.bounds.size.width/3*2,
                 isOpen: self.isSlideMenu,
                 menuClose: self.openMenu,
                 diaryExport: self.diaryExport)
      }//z
      .sheet(isPresented: $showShareSheet, content: {
        VStack{
          if let share = share, let note = shareNote {
            CloudSharingView(share: share, container: PersistenceController.shared.ckContainer, note: note)
              .ignoresSafeArea()
          }
        }
        .task {
          guard let shareNote = shareNote else { return }
          
          if !stack.isShared(object: shareNote) {
            print("공유설정중")
            Task {
              await createShare(shareNote)
            }
          }
          self.share = stack.getShare(shareNote)
        }
      })
      
      .sheet(isPresented: $isDelete) {
        VStack{
          Text("'\(notes[index].title)'을")
            .bold()
          Text("정말 삭제하시겠습니까?")
            .bold()
          
          Spacer()
          
          Button{
            isDelete = false
            viewContext.delete(notes[index])
            CoreDataSave()
          } label: {
            Text("지우기")
              .bold()
              .padding(12)
              .background(Color.gray.opacity(0.5))
              .cornerRadius(5)
          }
        }
        .padding([.top, .leading, .trailing])
        .presentationDetents([.fraction(0.25)])
      }
      .sheet(isPresented: $isRename) {
        VStack{
          Text("노트 이름 바꾸기")
            .bold()
          
          Spacer()
          
          VStack{
            TextField("노트 이름", text: $renameString)
              .disableAutocorrection(true)
              .textCase(.none)
            Divider()
              .onReceive(Just(renameString)) { _ in limitText(35) }
          }.frame(width: UIScreen.main.bounds.size.width/3*2)
          
          Spacer()
          
          Button{
            if renameString != "" {
              isRename = false
              notes[index].title = renameString
              CoreDataSave()
            }
          } label: {
            Text("바꾸기")
              .bold()
              .padding(12)
              .background(Color.gray.opacity(0.5))
              .cornerRadius(5)
          }
        }
        .padding([.top, .leading, .trailing])
        .presentationDetents([.fraction(0.25)])
      }

      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            openMenu()
            print("툴바")
          } label: {
            Image(systemName: "line.horizontal.3")
              .foregroundColor(.black)
          }
        }
        
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            noteAdd.toggle()
          } label: {
            Image(systemName: "plus")
              .foregroundColor(.black)
          }
        }
        
      } //toolbar
    }//navi
    .navigationViewStyle(StackNavigationViewStyle())
    .fullScreenCover(isPresented: $noteAdd) {
      NoteAddView()
    }
  }
  
  func diaryExport() {
//    withAnimation {
      self.isDiaryExport.toggle()
//    }
  }
  
  func openMenu() {
    withAnimation {
      self.isSlideMenu.toggle()
    }
  }
}



struct MenuContent: View {
  let diaryExport: () -> Void
  
  @AppStorage("StartMonday") var startMonday: Bool = UserDefaults.standard.bool(forKey: "StartMonday")
  @State var isDaySetting = false
  
    var body: some View {
      VStack{
        List{
          Text("앱이름...")
            .bold()
            .font(.title)
            .listRowSeparator(.hidden)
          
          Color.clear
            .listRowSeparator(.hidden)
          
          Button{
            isDaySetting.toggle()
          } label: {
            Text("한 주의 시작")
              .font(.system(size: 15, weight: .bold))
          }
          .onChange(of: isDaySetting, perform: { newValue in
//            print(newValue, "바뀜")
          })
//
          .confirmationDialog("현재 시작 요일: \(!startMonday ? "일요일" : "월요일")", isPresented: $isDaySetting, titleVisibility: .visible) {
            Button("일요일", role: .destructive) {
              startMonday = false
              CalendarModel.shared.refeshCalFistWeekday()
            }
            
            Button("월요일") {
              startMonday = true
              CalendarModel.shared.refeshCalFistWeekday()
            }

            Button("취소", role: .cancel) { }
          }
          
          Button{
            diaryExport()
          } label: {
            Text("다이어리 내보내기")
              .font(.system(size: 15, weight: .bold))
          }
          
          Text("도움말")
            .font(.system(size: 15, weight: .bold))
          
          Text("기타메뉴")
            .font(.system(size: 15, weight: .bold))
        }
        .listStyle(.plain)
//        Spacer()
        Text("version 1.0.0")
          .font(.footnote)
          .foregroundColor(.gray)
          .bold()
//        .padding([.leading, .trailing])
        
//        Text("For mk")
      }

    }
}

struct SideMenu: View {
  let width: CGFloat
  let isOpen: Bool
  let menuClose: () -> Void
  let diaryExport: () -> Void
  @State private var offset = CGSize.zero


  var body: some View {
    ZStack {
      GeometryReader { _ in
          EmptyView()
      }
      .background(Color.black.opacity(0.3))
      .opacity(self.isOpen ? 1.0 : 0.0)
      .onChange(of: isOpen, perform: { newValue in
        if newValue {
          withAnimation{
            offset = .zero
          }
        }
      })
      .onTapGesture {
        self.menuClose()
      }
      
      HStack {
        MenuContent(diaryExport: diaryExport)
          .frame(width: self.width)
          .background(Color.white)
          .offset(x: self.isOpen ? 0 + offset.width : -self.width)

        Spacer()
      }
    } //z
    .gesture(
      DragGesture()
        .onChanged { gesture in
          if gesture.translation.width < 0 {
            withAnimation(.linear(duration: 0)) {
              offset = gesture.translation
            }
          } else {
            if offset.width < 0 {
              withAnimation(.linear(duration: 0)) {
                offset.width = 0
              }
            }
          }
        }
        .onEnded { _ in
          if offset.width < -self.width/2 {
            self.menuClose()
          } else {
            withAnimation {
              offset = .zero
            }
          }
        }
    ) //gesture
  }
}
