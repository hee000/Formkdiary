//
//  TSET.swift
//  Formkdiary
//
//  Created by hee on 2022/10/26.
//

import SwiftUI
import CoreData

enum gridMove {
  case none
  case left
  case right
}

class PageGridModel: ObservableObject {
  init(note: NoteMO) {
    self.note = note
    if let newPages = note.pages.allObjects.sorted(by: {($0 as! PageMO).index < ($1 as! PageMO).index}) as? [PageMO] {
      self.pages = newPages
    } else {
      self.pages = []
    }
  }
  @Published var images: [NSManagedObjectID:UIImage] = [:]
  @Published var gridInnerSize: CGSize = CGSize()
  @Published var gridOuterSize: CGSize = CGSize()
  @Published var gridMove: gridMove = .none
  @Published var gridMoveIndex: Int = 0
  @Published var currentPage: PageMO?
  @Published var combinePage: CombinePage? = nil
  @Published var isCombine = false
  @Published var CombineConfirm = false {
    didSet {
      print("didSet - \(CombineConfirm)")
      if CombineConfirm {
        combine()
      }
    }
  }
  var pages: [PageMO]
  var note: NoteMO
  
  func loadImage() {
    if pages.isEmpty {
      return
    }
    
    for page in pages {
      var img: UIImage
      if let monthly = page.monthly {
        img = MonthlyDefaultView(monthly: monthly).asImage()
      } else if let weekly = page.weekly {
        img = WeeklyDefaultView(weekly: weekly).asImage()
      } else if let daily = page.daily {
        img = DailyViewOnPage(daily: daily).environmentObject(KeyboardManager()).asImage()
      } else {
        img = MemoView(memo: page.memo!).asImage()
      }
      images[page.objectID] = img
    }
  }
  
  func combine() {
    guard let fromPage = combinePage?.fromPage,
          let toPage = combinePage?.toPage
    else { return }
    let viewContext = PersistenceController.shared.context
    
    //    print("asdasd")
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
    
    if let newPages = note.pages.allObjects.sorted(by: {($0 as! PageMO).index < ($1 as! PageMO).index}) as? [PageMO] {
      pages = newPages
    }
    
    loadImage()
    
    combinePage = nil
    CombineConfirm = false
  }
}

struct CombinePage {
  var fromPage: PageMO?
  var toPage: PageMO?
}

class gridItemProvider: NSItemProvider {
    var didEnd: (() -> Void)?
    deinit {
        didEnd?()     // << here !!
    }
}

struct PageGridView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.presentationMode) var presentationMode
  @EnvironmentObject var keyboardManager: KeyboardManager

  @ObservedObject var note: NoteMO
  @StateObject var model: PageGridModel
  
  @Binding var pageIndex: Int32
  
  init(note: NoteMO, pageIndex: Binding<Int32>) {
    self.note = note
    
    let model = PageGridModel(note: note)
    _model = StateObject(wrappedValue: model)
    _pageIndex = pageIndex
  }
  
  @GestureState var tapGesture = false
  
  var body: some View {
    NavigationView{
      ScrollView{
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: Int(note.column)), spacing: 0){
          ForEach(Array(model.pages.enumerated()), id:\.element) { index, page in
            ZStack{
              GeometryReader{ outerGeo in
                Color.clear
                  .onAppear{
                    let size = outerGeo.size
                    if model.gridOuterSize != size {
                      model.gridOuterSize = size
                    }
                  }
              }
            
              Button{
//                guard let note = page.note else { return }
//                note.lastIndex = page.index
//                CoreDataSave()
                pageIndex = page.index
                presentationMode.wrappedValue.dismiss()
              } label: {
                HStack(spacing: 0) {
                  Color.clear
                    .frame(width: 7.5)
                    .overlay(model.gridMoveIndex == index && model.gridMove == .left ? Rectangle().frame(width: 1, height: nil).foregroundColor(Color.customText).offset(x: -0.5) : nil, alignment: .leading)
                    .padding([.top, .bottom], 3)
                    .contentShape(Rectangle())
                  
                  ZStack{
                    GeometryReader{ innerGeo in
                      Color.clear
                        .onAppear{
                          let size = innerGeo.size
                          if model.gridInnerSize != size {
                            model.gridInnerSize = size
                          }
                        }
                    }
                    VStack{
                      if let img = model.images[page.objectID]{
                        Image(uiImage: img)
                          .resizable()
                          .frame(height: UIScreen.main.bounds.size.height/(CGFloat(Int(note.column)) + 1))
                          .background(Color.customBg)
                          .cornerRadius(5)
                          .clipped()
                          .shadow(color: Color.customTextLight, radius: 2)
                      } else {
                        ProgressView()
                          .frame(maxWidth: .infinity)
                          .frame(height: UIScreen.main.bounds.size.height/(CGFloat(Int(note.column)) + 1))
                          .background(Color.customBg)
                          .cornerRadius(5)
                          .clipped()
                          .shadow(color: Color.customTextLight, radius: 2)
                      }
                      
                      if note.titleVisible {
                        Text(page.title)
                          .font(.system(size: 10, weight: .regular))
                          .lineLimit(1)
                      }
                    }//v
                  }//inner z
                  Color.clear
                    .frame(width: 7.5)
                    .overlay(model.gridMoveIndex == index && model.gridMove == .right ? Rectangle().frame(width: 1, height: nil).foregroundColor(Color.customText).offset(x: 0.5) : nil, alignment: .trailing)
                    .padding([.top, .bottom], 3)
                    .contentShape(Rectangle())
                  
                } // h
                .padding(.bottom, 15)
              }
            }//outer z
            .contextMenu {
              Button(role: .destructive) {
                for otherPage: PageMO in page.note!.pages.toArray() {
                  if otherPage.index > page.index{
                    otherPage.index -= 1
                  }
                }
                viewContext.delete(page)
                CoreDataSave()
                
                if let newPages = model.note.pages.allObjects.sorted(by: {($0 as! PageMO).index < ($1 as! PageMO).index}) as? [PageMO] {
                  model.pages = newPages
                }
                
                model.loadImage()
                print("삭제")
              } label: {
                Label("지우기", systemImage: "trash.fill")
              }
            }
            .onDrag {
              model.currentPage = page
              return NSItemProvider(object: "\(page.objectID)" as NSString)
            }
            .onDrop(of: [.text], delegate: PageGridDrag(page: page, model: model))
          }//for
        }//lazyV
        .padding([.leading, .trailing])
      }//scroll
      .background(Color.customBg)
      .navigationTitle(note.title)
      .navigationBarTitleDisplayMode(.inline)
      .overlay(self.model.isCombine ? AlertTwoButton(isPresented: $model.isCombine, confirm: $model.CombineConfirm) {
        Text("페이지를 합칠까요?")
          .font(.system(size: 16, weight: .regular))
          .foregroundColor(Color.customText)} : nil )
    }//navi
    .task {
      model.loadImage()
    }
  }
}
