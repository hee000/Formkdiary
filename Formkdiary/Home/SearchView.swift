//
//  SearchView.swift
//  Formkdiary
//
//  Created by hee on 2022/10/27.
//

import SwiftUI


enum naviType: Hashable {
    case note, page
}


class SearchNavigator: ObservableObject {
  @Published var isNote = false
  @Published var note: NoteMO?
  @Published var isPage = false
  @Published var page: PageMO?
  @Published var navi: [naviType] = []
}

struct zzzzzzzzz: View {
  @Environment(\.presentationMode) var presentationMode
  @State var keyword = ""
  let onSearchNavigator: () -> Void
  let note: NoteMO?
  
  init(onSearchNavigator: @escaping () -> Void, note: NoteMO? = nil) {
    self.onSearchNavigator = onSearchNavigator
    self.note = note
  }
  
  var body: some View {
    NavigationView{
      VStack{
        VStack{
          TextField("검색어를 입력해주세요.", text: $keyword)
          Divider()
        }
        .padding()
        
        if !keyword.isEmpty {
          SearchView(keyword: keyword, onSearchNavigator: onSearchNavigator, note: note != nil ? note! : nil)
        } else {
          Spacer()
        }
      }//v
      .background(Color.customBg)
      .navigationTitle("검색하기")
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarBackButtonHidden(true)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            presentationMode.wrappedValue.dismiss()
          } label: {
            Image(systemName: "xmark")
              .foregroundColor(Color.customText)
          }
        }
      }//toolbar
    }//navi
  }
}

import CoreData
struct SearchView: View {
  @Environment(\.presentationMode) var presentationMode
  @EnvironmentObject var searchNavigator: SearchNavigator

  let backgroundContext = PersistenceController.shared.backgroundContext


  var titlePage: [PageMO]

  var textDaily: [DailyMO]
  let stack = PersistenceController.shared

//  var textMemo: [MemoMO]

  let keyword: String

  private var onNote: Bool
  let onSearchNavigator: () -> Void

  init(keyword: String, onSearchNavigator: @escaping () -> Void, note: NoteMO? = nil) {

    self.onSearchNavigator = onSearchNavigator
    self.keyword = keyword

    var titlePredicate: NSPredicate
    var textPredicate: NSPredicate
//    var titlePredicate: NSPredicate
    let reg = "^.*\(keyword).*$"

    if let note = note {
      let pageNotePredicate = NSPredicate(format: "note == %@", note)
      let pageTitlePredicate = NSPredicate(format: "title MATCHES %@", reg)
      titlePredicate = NSCompoundPredicate(type: .and, subpredicates: [pageNotePredicate, pageTitlePredicate])


      let notePredicate = NSPredicate(format: "page.note == %@", note)
      let keywordPredicate = NSPredicate(format: "text MATCHES %@", reg)
      textPredicate = NSCompoundPredicate(type: .and, subpredicates: [notePredicate, keywordPredicate])
      self.onNote = true
    } else {
      titlePredicate = NSPredicate(format: "title MATCHES %@", reg)
      textPredicate = NSPredicate(format: "text MATCHES %@", reg)
      self.onNote = false
    }

    let pageFetchRequest = NSFetchRequest<PageMO>(entityName: "Page")
    pageFetchRequest.predicate = titlePredicate
    titlePage = try! backgroundContext.fetch(pageFetchRequest)


    let dailyFetchRequest = NSFetchRequest<DailyMO>(entityName: "Daily")
    dailyFetchRequest.predicate = textPredicate
    textDaily = try! backgroundContext.fetch(dailyFetchRequest)



//    self.titlePage = titlePage
//    self.textDaily = textDaily
//    _textDaily = FetchRequest(entity: DailyMO.entity(), sortDescriptors: [], predicate: textPredicate)
//
//    _textMemo = FetchRequest(entity: MemoMO.entity(), sortDescriptors: [], predicate: textPredicate)
//
//    _titlePage = FetchRequest(entity: PageMO.entity(), sortDescriptors: [], predicate: titlePredicate)

  }

  var body: some View {
    ScrollView{
      LazyVStack(alignment: .leading) {

        if titlePage.isEmpty && textDaily.isEmpty {
          Text("일치하는 다이어리가 없습니다.")
            .padding(.leading)
        }

        if !titlePage.isEmpty {
          Text("제목")
            .padding(.leading)
        }
        ForEach(titlePage) { page in
          Button{
            onSearchNavigator()

            if onNote {
              searchNavigator.page = page
              searchNavigator.isPage = true
//              searchNavigator.navi.append(.page)
            } else {
              guard let note = page.note else { return }
              searchNavigator.note = note
              searchNavigator.isNote = true
              searchNavigator.page = page
              searchNavigator.isPage = true
            }
          } label: {
            HStack{
              Rectangle()
                .frame(width: 15, height: 1)
                .foregroundColor(Color.customText)

              Text("\(page.title)")
                .lineLimit(1)
                .foregroundColor(Color.customText)
            }
          }
        }//for

        if !textDaily.isEmpty {
          Text("내용")
            .padding([.leading, .top])
        }
        ForEach(textDaily) { backDaily in
          Button{
            onSearchNavigator()

            let FetchRequest = NSFetchRequest<DailyMO>(entityName: "Daily")
            FetchRequest.predicate = NSPredicate(format: "dailyId == %@", backDaily.dailyId as CVarArg)
            
            let daily = try! stack.context.fetch(FetchRequest).first!
            
            if let page = daily.page {
              if onNote {
                searchNavigator.page = page
                searchNavigator.isPage = true
              } else {
                guard let note = page.note else { return }
                searchNavigator.note = note
                searchNavigator.isNote = true
                searchNavigator.page = page
                searchNavigator.isPage = true
              }
            } else if let monthly = daily.monthly {
              guard let page = monthly.page else { return }
              if onNote {
                searchNavigator.page = page
                searchNavigator.isPage = true
              } else {
                guard let note = page.note else { return }
                searchNavigator.note = note
                searchNavigator.isNote = true
                searchNavigator.page = page
                searchNavigator.isPage = true
              }
            } else if let weekly = daily.weekly {
              guard let page = weekly.page else { return }
              if onNote {
                searchNavigator.page = page
                searchNavigator.isPage = true
              } else {
                guard let note = page.note else { return }
                searchNavigator.note = note
                searchNavigator.isNote = true
                searchNavigator.page = page
                searchNavigator.isPage = true
              }
            }
          } label: {
            HStack{
              Rectangle()
                .frame(width: 15, height: 1)
                .foregroundColor(Color.customText)

              Text(backDaily.text)
                .lineLimit(1)
                .foregroundColor(Color.customText)
            }
          }
        }//for
      }//lazyV
//          .padding()
    }//scroll
  }
}


//struct SearchView: View {
//  @Environment(\.presentationMode) var presentationMode
//  @EnvironmentObject var searchNavigator: SearchNavigator
//
//
//  @FetchRequest var titlePage: FetchedResults<PageMO>
//
//  @FetchRequest var textDaily: FetchedResults<DailyMO>
//  @FetchRequest var textMemo: FetchedResults<MemoMO>
//
//
//  private var onNote: Bool
//  let onSearchNavigator: () -> Void
//
//  init(keyword: String, onSearchNavigator: @escaping () -> Void, note: NoteMO? = nil) {
//
//    self.onSearchNavigator = onSearchNavigator
//
//    var titlePredicate: NSPredicate
//    var textPredicate: NSPredicate
////    var titlePredicate: NSPredicate
//    let reg = "^.*\(keyword).*$"
//
//    if let note = note {
//      let pageNotePredicate = NSPredicate(format: "note == %@", note)
//      let pageTitlePredicate = NSPredicate(format: "title MATCHES %@", reg)
//      titlePredicate = NSCompoundPredicate(type: .and, subpredicates: [pageNotePredicate, pageTitlePredicate])
//
//
//      let notePredicate = NSPredicate(format: "page.note == %@", note)
//      let keywordPredicate = NSPredicate(format: "text MATCHES %@", reg)
//      textPredicate = NSCompoundPredicate(type: .and, subpredicates: [notePredicate, keywordPredicate])
//      self.onNote = true
//    } else {
//      titlePredicate = NSPredicate(format: "title MATCHES %@", reg)
//      textPredicate = NSPredicate(format: "text MATCHES %@", reg)
//      self.onNote = false
//    }
//
//
////    self.titlePage = titlePage
////    self.textDaily = textDaily
//    _textDaily = FetchRequest(entity: DailyMO.entity(), sortDescriptors: [], predicate: textPredicate)
//
//    _textMemo = FetchRequest(entity: MemoMO.entity(), sortDescriptors: [], predicate: textPredicate)
//
//    _titlePage = FetchRequest(entity: PageMO.entity(), sortDescriptors: [], predicate: titlePredicate)
//
//  }
//
//  var body: some View {
//    ScrollView{
//      LazyVStack(alignment: .leading) {
//
//        if titlePage.isEmpty && textDaily.isEmpty {
//          Text("일치하는 다이어리가 없습니다.")
//            .padding(.leading)
//        }
//
//        if !titlePage.isEmpty {
//          Text("제목")
//            .padding(.leading)
//        }
//        ForEach(titlePage) { page in
//          Button{
//            onSearchNavigator()
//
//            if onNote {
//              searchNavigator.page = page
//              searchNavigator.isPage = true
////              searchNavigator.navi.append(.page)
//            } else {
//              guard let note = page.note else { return }
//              searchNavigator.note = note
//              searchNavigator.isNote = true
//              searchNavigator.page = page
//              searchNavigator.isPage = true
//            }
//          } label: {
//            HStack{
//              Rectangle()
//                .frame(width: 15, height: 1)
//                .foregroundColor(Color.customText)
//
//              Text("\(page.title)")
//                .lineLimit(1)
//                .foregroundColor(Color.customText)
//            }
//          }
//        }//for
//
//        if !textDaily.isEmpty {
//          Text("내용")
//            .padding([.leading, .top])
//        }
//        ForEach(textDaily) { daily in
//          Button{
//            onSearchNavigator()
//
//            if let page = daily.page {
//              if onNote {
//                searchNavigator.page = page
//                searchNavigator.isPage = true
//              } else {
//                guard let note = page.note else { return }
//                searchNavigator.note = note
//                searchNavigator.isNote = true
//                searchNavigator.page = page
//                searchNavigator.isPage = true
//              }
//            } else if let monthly = daily.monthly {
//              guard let page = monthly.page else { return }
//              if onNote {
//                searchNavigator.page = page
//                searchNavigator.isPage = true
//              } else {
//                guard let note = page.note else { return }
//                searchNavigator.note = note
//                searchNavigator.isNote = true
//                searchNavigator.page = page
//                searchNavigator.isPage = true
//              }
//            } else if let weekly = daily.weekly {
//              guard let page = weekly.page else { return }
//              if onNote {
//                searchNavigator.page = page
//                searchNavigator.isPage = true
//              } else {
//                guard let note = page.note else { return }
//                searchNavigator.note = note
//                searchNavigator.isNote = true
//                searchNavigator.page = page
//                searchNavigator.isPage = true
//              }
//            }
//          } label: {
//            HStack{
//              Rectangle()
//                .frame(width: 15, height: 1)
//                .foregroundColor(Color.customText)
//
//              Text(daily.text)
//                .lineLimit(1)
//                .foregroundColor(Color.customText)
//            }
//          }
//        }//for
//      }//lazyV
////          .padding()
//    }//scroll
//  }
//}
