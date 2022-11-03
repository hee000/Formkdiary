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

let noteStyleRange = [Int32(0), Int32(1), Int32(2)]

struct NoteSettingView: View {
  @Environment(\.presentationMode) var presentationMode
  @EnvironmentObject var navigator: Navigator

  @State private var isToast = false
  @State private var isToastMessage = ""

  @ObservedObject var note: NoteMO
  @ObservedObject var page: PageMO
  
  
  @State var column: Int
  @State var isDiaryExportText = false
  @State var isDiaryExportImage = false
  
  @State var isSearch = false
  
  
  @State private var share: CKShare?
  @State private var shareNote: NoteMO?
  @State private var showShareSheet = false
  let stack = PersistenceController.shared
  
  func onSearchNavigator() {
    presentationMode.wrappedValue.dismiss()
    isSearch.toggle()
//    presentationMode.wrappedValue.dismiss()
  }
  
  init(note: NoteMO, page: PageMO? = nil) {
//    if let note = try? context.existingObject(with: objectID) as? NoteMO {
//        self.note = note
//        _column = State(initialValue: Int(note.column))
//    } else {
//        // if there is no object with that id, create new one
//      let note = NoteMO(context: context)
//        self.note = note
//        _column = State(initialValue: Int(note.column))
//        try? context.save()
//    }
    self.note = note
    _column = State(initialValue: Int(note.column))
    
    if let page = page {
      self.page = page
    } else {
      self.page = PageMO(context: note.managedObjectContext!)
    }
//    if let pid = pageObjectID, let page = try? context.existingObject(with: pid) as? PageMO {
//      self.page = page
////      print(page)
//    } else {
//      self.page = PageMO(context: context)
//    }
  }
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading) {
          Text("노트 설정")
            .font(.system(size: 20, weight: .bold))
            .padding(.vertical)
          
          HStack {
            Text("페이지 보기 방식")
              .font(.system(size: 15, weight: .regular))
              .padding(.trailing)
            Picker("column picker", selection: $note.style) {
              ForEach(noteStyleRange, id:\.self) { style in
                if style == noteStyle.list.rawValue{
                  Text("목록")
                    .font(.system(size: 15, weight: .regular))
                } else if style == noteStyle.page.rawValue {
                  Text("페이지")
                    .font(.system(size: 15, weight: .regular))
                }
              }
            }
            .onChange(of: note.style, perform: { _ in
              CoreDataSave()
            })
            .pickerStyle(SegmentedPickerStyle())
          }
          .frame(height: UIScreen.main.bounds.size.width/14)
          .padding(.vertical)
          
          Divider()
          
          if note.style == noteStyle.page.rawValue {
            HStack {
              Text("페이지 개수")
                .font(.system(size: 15, weight: .regular))
              Spacer()
              
              Picker("column picker", selection: $column) {
                ForEach(SettingColumnRange, id:\.self) { column in
                  Text("\(column)")
                    .foregroundColor(Color.customText)
                }
              }
              .foregroundColor(Color.customIc)
              //              .background(Color.customIc)
              .tint(Color.customIc)
              //              .pickerStyle(SegmentedPickerStyle())
            }
            .frame(height: UIScreen.main.bounds.size.width/14)
            .padding(.vertical)
            
            Divider()
            
            Toggle(isOn: $note.titleVisible) {
              Text("페이지 이름 보기")
                .font(.system(size: 15, weight: .regular))
                .frame(height: UIScreen.main.bounds.size.width/14)
                .padding(.vertical)
            }
            .toggleStyle(SwitchToggleStyle())
            .tint(.gray)
            .onChange(of: note.titleVisible) { _ in
              CoreDataSave()
            }
            
            Divider()
          }
          
          if note.style == noteStyle.list.rawValue {
            NavigationLink(destination: PageListEditView(note: note)) {
              Text("순서 바꾸기")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color.customText)
                .frame(height: UIScreen.main.bounds.size.width/14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical)
            }
            
            Divider()
          }
          
//          if note.style == 0 {
            Button{
              isSearch.toggle()
            } label: {
              Text("검색")
                .font(.system(size: 15, weight: .regular))
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: UIScreen.main.bounds.size.width/14)
                .foregroundColor(Color.customText)
                .padding(.vertical)
            }
            
            Divider()
//          }
          
          
          if let share = stack.getShare(note), share.participants.count > 1  {
            Button {
              self.share = nil
              shareNote = note
              showShareSheet = true
            } label: {
              Text("공유설정")
                .font(.system(size: 15, weight: .regular))
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: UIScreen.main.bounds.size.width/14)
                .foregroundColor(Color.customText)
                .padding(.vertical)
            }
            
            Divider()
          }
          
          
          if page.note != nil {
            Text("페이지 설정")
              .font(.system(size: 20, weight: .bold))
              .padding(.vertical)
            
            Text("이름")
              .bold()
              .font(.system(size: 15, weight: .regular))
            //              .padding(.trailing)
            
            TextField("제목", text: $page.title)
              .onChange(of: page.title) { newValue in
                CoreDataSave()
              }
              .font(.system(size: 15, weight: .regular))
              .padding()
              .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.7), lineWidth: 1))
            
            Divider()
            
            if let weekly = page.weekly {
              Text("스타일")
                .bold()
              
              HStack{
                Button{
                  weekly.style = weeklyStyle.two.rawValue
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
                  weekly.style = weeklyStyle.one.rawValue
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
              HStack{
                Image(systemName: "square.and.arrow.up")
                  .foregroundColor(Color.customIc)
                Text("내보내기")
                  .foregroundColor(Color.customText)
                  .font(.system(size: 15, weight: .regular))
                Spacer()
              }
              .frame(height: UIScreen.main.bounds.size.width/14)
              .padding(.vertical)
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
            
            Button{
              presentationMode.wrappedValue.dismiss()
            
              for otherPage: PageMO in page.note!.pages.toArray() {
                if otherPage.index > page.index{
                  otherPage.index -= 1
                }
              }
              stack.context.delete(page)
              CoreDataSave()
            }label: {
              Text("페이지 삭제")
                .foregroundColor(Color.customText)
                .font(.system(size: 15, weight: .regular))
                .frame(height: UIScreen.main.bounds.size.width/14)
                .padding(.vertical)
            }
          } //page
          
          
        }//v
        .padding([.leading, .trailing])
        .padding([.leading, .trailing])
      } //scroll
      .foregroundColor(Color.customText)
      .background(Color.customBg)
      .sheet(isPresented: $isSearch) {
        SearchView(onSearchNavigator: onSearchNavigator, note: note)
//          .onDisappear{
//            if let note = navigator.note {
//              navigator.path.append(Route.note(note))
//            }
//            if let page = navigator.page {
//              navigator.path.append(Route.page(page))
//            }
//            navigator.note = nil
//            navigator.page = nil
//          }
      }
      .sheet(isPresented: $showShareSheet, content: {
        VStack{
          if let share = share, let note = shareNote {
            CloudSharingView(share: share, container: PersistenceController.shared.ckContainer, note: note)
              .ignoresSafeArea()
              .tint(Color.customText)
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
      .navigationTitle("노트/페이지 설정")
      .navigationBarTitleDisplayMode(.inline)
//      .navigationBarBackButtonHidden(true)
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
    .toast(message: isToastMessage, isShowing: $isToast, duration: Toast.short)
  }
}
