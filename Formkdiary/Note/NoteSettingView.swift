//
//  SettingView.swift
//  Formkdiary
//
//  Created by cch on 2022/09/17.
//

import SwiftUI
import CoreData
import Photos
import CloudKit

let SettingColumn = (UserDefaults.standard.integer(forKey: "Setting-Column") != 0) ? UserDefaults.standard.integer(forKey: "Setting-Column") : 2

let SettingColumnRange = [2, 3, 4]

struct NoteSettingView: View {
  @Environment(\.presentationMode) var presentationMode
  @EnvironmentObject var pageNavi: PageNavi

  @State private var isToast = false
  @State private var isToastMessage = ""

  @ObservedObject var note: NoteMO
  @ObservedObject var page: PageMO
  
  
  @State var column: Int
  @State var isDiaryExportText = false
  @State var isDiaryExportImage = false
  
  
  @State private var share: CKShare?
  @State private var shareNote: NoteMO?
  @State private var showShareSheet = false
  let stack = PersistenceController.shared
  
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
            
            if let share = stack.getShare(note), share.participants.count > 1  {
              Button {
                self.share = nil
                shareNote = note
                showShareSheet = true
              } label: {
                Text("공유설정")
                  .bold()
              }
              
              Divider()
                .padding([.top, .bottom])
            }
          
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

            Divider()
              .padding([.top, .bottom])
            
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
              
              Divider()
                .padding([.top, .bottom])
            } // style
            
            Menu{
              Button {isDiaryExportText.toggle()
                
              } label: {
                Label("텍스트 내보내기", systemImage: "doc.plaintext")
              }
//              Button("이미지 내보내기") {isDiaryExportImage.toggle()}
              Button {
                let image = exportDiary().image(page: page)
                PHPhotoLibrary.shared().performChanges {
                    _ = PHAssetChangeRequest.creationRequestForAsset(from: image)
                } completionHandler: { (success, error) in
                  if success {
                    self.isToastMessage = "앨범에 저장되었습니다."
                    self.isToast.toggle()
                  } else {
                    self.isToastMessage = "앨범 저장에 실패했습니다."
                    self.isToast.toggle()
                  }
                }
              } label: {
                Label("이미지 저장하기", systemImage: "photo")
              }
            } label: {
              Label("내보내기", systemImage: "square.and.arrow.up")
//              Text("내보내기")
            }
            .background(SharingViewController(isPresenting: $isDiaryExportText) {
              let text = exportDiary().text(page: page)
              
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
                 isDiaryExportText = false // required for re-open !!!
                  }
                  return av
              })
            
            Divider()
              .padding([.top, .bottom])
          } //page
          
          
        }//v
        .padding([.leading, .trailing])
        .padding([.leading, .trailing])
      } //scroll
      .sheet(isPresented: $showShareSheet, content: {
        VStack{
          if let share = share, let note = shareNote {
            CloudSharingView(share: share, container: PersistenceController.shared.ckContainer, note: note)
              .ignoresSafeArea()
          }
        }
        .task {
          guard let shareNote = shareNote else { return }
          self.share = stack.getShare(shareNote)
        }
      })
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
    .toast(message: isToastMessage, isShowing: $isToast, duration: Toast.short)
  }
}
