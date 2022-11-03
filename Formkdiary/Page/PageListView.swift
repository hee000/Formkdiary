//
//  PageListView.swift
//  Formkdiary
//
//  Created by hee on 2022/10/22.
//

import SwiftUI
import UniformTypeIdentifiers
import Combine

class PageListModel: ObservableObject{
  @Published var pages: [PageMO] = []
  @Published var currentPage: PageMO?
  @Published var combinePage: CombinePage? = nil
  @Published var isCombine = false
  @Published var CombineConfirm = false
}


struct PageListView: View {
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.managedObjectContext) private var viewContext

  @ObservedObject var note: NoteMO
  @StateObject var model = PageListModel()
  
  @FetchRequest var pages : FetchedResults<PageMO>
  
  @State var isPageAdd = false
  @State var isNoteSetting = false

  init(note: NoteMO) {
    self.note = note
    
    var predicate = NSPredicate(format: "note == %@", note)
    _pages = FetchRequest(entity: PageMO.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \PageMO.index, ascending: true)], predicate: predicate)
  }
  
  
  
  var body: some View {
    ScrollView {
      LazyVStack(spacing: 0){
        ForEach(Array(pages.enumerated()), id:\.element) { index, page in
          NavigationLink(value: Route.page(page)) {
            HStack{
              Rectangle()
                .frame(width: 20, height: 1)
                .foregroundColor(Color.customText)
              
              Text(page.title)
            }
            .padding([.trailing, .top, .bottom])
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .onDisappear{
              note.lastIndex = page.index
            }
          }
          .contentShape(Rectangle())
          .contextMenu {
            Button(role: .destructive) {
              for otherPage: PageMO in page.note!.pages.toArray() {
                if otherPage.index > page.index{
                  otherPage.index -= 1
                }
              }
              viewContext.delete(page)
              CoreDataSave()
              print("삭제")
            } label: {
              Label("지우기", systemImage: "trash.fill")
            }
          }
          .onDrag {
            model.currentPage = page
            return NSItemProvider(object: "\(page.objectID)" as NSString)
          }
          .onDrop(of: [.text], delegate: PageListDrag(page: page, model: model))
          
        } //for
      }//lazyV
    }//scroll
    .onReceive(note.publisher(for: \.pages), perform: { _ in
      model.pages = pages.map{$0}
    })
    .overlay(self.model.isCombine ? AlertTwoButton(isPresented: $model.isCombine, confirm: $model.CombineConfirm) { Text("페이지를 합칠까요?").font(.system(size: 16, weight: .regular))} : nil )
    .onChange(of: model.CombineConfirm, perform: { newValue in
      //      print("합치기 시작")
      if newValue {
        guard let fromPage = model.combinePage?.fromPage,
              let toPage = model.combinePage?.toPage
        else { return }
        
        print("asdasd")
        if let toMontly = toPage.monthly {
          if let fromWeekly = fromPage.weekly { // 먼-위
            if CalendarModel.shared.calendar.isDate(fromWeekly.date, equalTo: toMontly.date, toGranularity: .month) {
              for daily: DailyMO in fromWeekly.dailies.toArray() {
                daily.weekly = nil
                daily.monthly = toMontly
              }
              for otherPage: PageMO in note.pages.toArray() {
                if otherPage.index > fromPage.index{
                  otherPage.index -= 1
                }
              }
              viewContext.delete(fromPage)
            }
          } else if let fromDaily = fromPage.daily { // 먼-데
            if CalendarModel.shared.calendar.isDate(fromDaily.date, equalTo: toMontly.date, toGranularity: .month) {
              if fromDaily.text != "" {
                fromDaily.page = nil
                fromDaily.monthly = toMontly
              }
              for otherPage: PageMO in note.pages.toArray() {
                if otherPage.index > fromPage.index{
                  otherPage.index -= 1
                }
              }
              viewContext.delete(fromPage)
            }
          }
          
        } else if let toWeekly = toPage.weekly {
          if let fromDaily = fromPage.daily { // 위-데
            if CalendarModel.shared.calendar.isDate(fromDaily.date, equalTo: toWeekly.date, toGranularity: .weekOfYear) {
              if fromDaily.text != "" {
                fromDaily.page = nil
                fromDaily.weekly = toWeekly
              }
              for otherPage: PageMO in note.pages.toArray() {
                if otherPage.index > fromPage.index{
                  otherPage.index -= 1
                }
              }
              viewContext.delete(fromPage)
            }
          }
        }
        
        CoreDataSave()
        
        model.combinePage = nil
        model.CombineConfirm = false
      }
    })
    .fullScreenCover(isPresented: $isPageAdd) {
      PageAddView(note: note)
    }
    .fullScreenCover(isPresented: $isNoteSetting) {
      NoteSettingView(note: note)
    }
    .navigationTitle(note.title)
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          presentationMode.wrappedValue.dismiss()
        } label: {
          Image(systemName: "chevron.left")
            .foregroundColor(Color.customIc)
        }
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        HStack {
          Button {
            isPageAdd.toggle()
          } label: {
            Image(systemName: "plus")
              .foregroundColor(Color.customIc)
          }
          
          Button {
            isNoteSetting.toggle()
          } label: {
            Image(systemName: "gearshape")
              .foregroundColor(Color.customIc)
          }
        }
      }
    }//toolbar
  }
}
