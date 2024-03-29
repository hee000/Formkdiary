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
  
  @State var isSetting = false
  @State var isSearch = false
  
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
  
  @EnvironmentObject var navigator: Navigator

  var body: some View {
//    NavigationStack {
      ZStack{
        Color.customBg.ignoresSafeArea()
        
        GeometryReader { geometry in                    // Get the geometry
          ScrollView{
            VStack{
              ForEach(Array(notes.enumerated()), id:\.element) { index, note in
                
                NavigationLink(value: Route.note(note)) {
                  HStack{
                    if let share = stack.getShare(note), share.participants.count > 1 {
                      Image(systemName: "person.2.fill")
                    }
                    Text(note.title)
                      .lineLimit(1)
                  }
                  .padding(10)
                  .frame(maxWidth: .infinity)
                  .foregroundColor(Color.customText)
                }
                .buttonStyle(PlainButtonStyle())
                .contextMenu {
                  Button {
                    share = nil
                    shareNote = note
                    showShareSheet = true
                  } label: {
                    Label("공유", systemImage: "person.2.fill")
                  }
                  
                  Button {
                    self.index = index
                    self.renameString = note.title
                    
                    withAnimation{
                      isRename.toggle()
                    }
                    print("리네임")
                  } label: {
                    Label("이름 변경", systemImage: "pencil")
                  }
                  
//                  if stack.isOwner(object: note) {
                    Button(role: .destructive) {
                      self.index = index
                      withAnimation{
                        isDelete.toggle()
                      }
                      print("삭제")
                    } label: {
                      Label("삭제", systemImage: "trash.fill")
                    }
                    .tint(.red)
//                  }
                }
              } //for
            }//v
            .padding([.leading, .trailing])
            .frame(width: geometry.size.width)
            .frame(minHeight: geometry.size.height)
          } //scroll
          .clipped()
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
          
        }//geo
        .background(Color.customBg)
        .fullScreenCover(isPresented: $isSetting) {
          SettingView()
        }
        .fullScreenCover(isPresented: $noteAdd) {
          NoteAddView()
        }
        
        .sheet(isPresented: $showShareSheet, content: {
          VStack{
            if let share = share, let note = shareNote {
              CloudSharingView(share: share, container: PersistenceController.shared.ckContainer, note: note)
                .ignoresSafeArea()
                .tint(Color.customText)
            } else  {
              ProgressView()
            }
          }
          .task {
            guard let shareNote = shareNote else { return }
            
            if !stack.isShared(object: shareNote) {
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
                .background(Color.customBg)
                .cornerRadius(5)
            }
          }
          .padding([.top, .leading, .trailing])
          .presentationDetents([.fraction(0.25)])
        }
        
        .sheet(isPresented: $isSearch) {
          SearchView(onSearchNavigator: onSearchNavigator)
            .onDisappear{
              if let note = navigator.note {
                navigator.path.append(Route.note(note))
              }
              if let page = navigator.page {
                navigator.path.append(Route.page(page))
              }
              navigator.note = nil
              navigator.page = nil
            }
        }
        
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button {
              openMenu()
//              print("툴바")
            } label: {
              Image(systemName: "line.horizontal.3")
                .foregroundColor(Color.customIc)
            }
          }
          
          
          ToolbarItem(placement: .navigationBarTrailing) {
            Button {
              noteAdd.toggle()
            } label: {
              Image(systemName: "plus")
                .foregroundColor(Color.customIc)
            }
          }
          
        } //toolbar
        
        SideMenu(width: UIScreen.main.bounds.size.width/3*2,
                 isOpen: self.isSlideMenu,
                 menuClose: self.openMenu,
                 diaryExport: self.diaryExport,
                 openSetting: self.openSetting,
                 openSearch: self.openSearch)
      }//z
  }
  
  func onSearchNavigator() {
    self.isSlideMenu = false
    self.isSearch = false
  }
  
  
  func diaryExport() {
      self.isDiaryExport.toggle()
  }
  
  func openSetting() {
    withAnimation {
      self.isSetting.toggle()
    }
  }
  
  func openMenu() {
    withAnimation {
      self.isSlideMenu.toggle()
    }
  }
  
  func openSearch() {
    withAnimation {
      self.isSearch.toggle()
    }
  }
}

//펜다곰의 펜시한 다이어리!
