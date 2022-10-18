//
//  PageSelectView.swift
//  Formkdiary
//
//  Created by cch on 2022/07/01.
//

import SwiftUI
import CoreData

enum gridMove {
  case none
  case left
  case right
}
//
//extension CGSize: Hashable {
//    public var hashValue: Int {
//        return NSCoder.string(for: self).hashValue
//    }
//}

struct Grid: Identifiable, Hashable, Equatable {
  var id = UUID().uuidString
  var gridText: String
  var gridImg: UIImage
  var gridPage: PageMO
  var gridMove: gridMove = .none
}

struct CombinePage {
  var fromPage: PageMO?
  var toPage: PageMO?
}

class GridViewModel: ObservableObject{
  @Published var gridItems: [Grid] = []
  @Published var currentGrid: Grid?
  @Published var currentGridOverlay: Grid?
  @Published var gridInnerSize: CGSize = CGSize()
  @Published var gridOuterSize: CGSize = CGSize()
  @Published var combinePage: CombinePage? = nil
  @Published var isCombine = false
  @Published var CombineConfirm = false
}

struct PageSelectView: View {
  @Environment(\.managedObjectContext) private var viewContext

  @ObservedObject var note: NoteMO
  var pages: [PageMO]

  @ViewBuilder
  func imgEffect(img: UIImage, column: Int16, page: PageMO, titleVisible: Bool, grid: Grid, isDrag: Bool) -> some View {
    ZStack{
      GeometryReader{ outerGeo in
        Color.clear
          .onAppear{
            let size = outerGeo.size
            if gridData.gridOuterSize != size {
              gridData.gridOuterSize = size
            }
          }
      }
      
      HStack(spacing: 0) {
        Color.clear
          .frame(width: 7.5)
          .overlay(grid.gridMove == .left ? Rectangle().frame(width: 1, height: nil).foregroundColor(Color.black).offset(x: -0.5) : nil, alignment: .leading)
          .padding([.top, .bottom], 3)
          .contentShape(Rectangle())

        
        ZStack{
          GeometryReader{ innerGeo in
            Color.clear
              .onAppear{
                let size = innerGeo.size
                if gridData.gridInnerSize != size {
                  gridData.gridInnerSize = size
                }
              }
          }
          VStack{
            Image(uiImage: img)
              .resizable()
              .frame(height: UIScreen.main.bounds.size.height/(CGFloat(Int(column)) + 1))
              .background(Color.white)
              .cornerRadius(5)
              .clipped()
              .shadow(color: Color.black.opacity(0.2), radius: 2)
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
            
            if titleVisible {
              Text(page.title)
                .font(.system(size: 10, weight: .regular))
                .lineLimit(1)
            }
          } //v
          
          if isDrag {
            Color.black.opacity(0.2)
              .cornerRadius(5)
          }
        } //z
        
        Color.clear
          .frame(width: 7.5)
          .overlay(grid.gridMove == .right ? Rectangle().frame(width: 1, height: nil).foregroundColor(Color.black).offset(x: 0.5) : nil, alignment: .trailing)
          .padding([.top, .bottom], 3)
          .contentShape(Rectangle())

      } // h
      .padding(.bottom, 15)
    }
    .onDrag {
      gridData.currentGrid = grid
      return NSItemProvider(object: grid.gridText as NSString)
    }
    .onDrop(of: [.text], delegate: DragRelocateDelegate(grid: grid, gridData: gridData))
  }
  
  @StateObject var gridData = GridViewModel()
  
  @State var pageRenderImage: [UIImage] = []
                    
  @State private var dragging: PageMO?
  
  var body: some View {
    ScrollView{
      LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: Int(note.column)), spacing: 0){
        ForEach(Array(zip(pages.indices, gridData.gridItems)), id: \.1) { index, grid in
          let page = pages[index]
            NavigationLink(destination: PageView(note: note, pageIndex: index, pages: pages)){
              imgEffect(img: grid.gridImg, column: note.column, page: page, titleVisible: note.titleVisible, grid: grid, isDrag: gridData.currentGrid == grid)
            }
            .onAppear{
              print(page.index)
            }
        } //for
        
        
      } //lazyv
//      .animation(.default, value: gridData.gridItems)
      .onAppear(perform: {
        DispatchQueue.main.async {
          let result = createImg(pages: pages)
          pageRenderImage = result.imgs
          gridData.gridItems = result.model
        }
      })
      .onChange(of: pages, perform: { new in
        DispatchQueue.main.async {
          let result = createImg(pages: new)
          pageRenderImage = result.imgs
          gridData.gridItems = result.model
        }
      })
      
      .padding(7.5)
      
    } //scroll
    .onChange(of: gridData.CombineConfirm, perform: { newValue in
//      print("합치기 시작")
      if newValue {
        guard let fromPage = gridData.combinePage?.fromPage,
              let toPage = gridData.combinePage?.toPage
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
        
        gridData.combinePage = nil
        gridData.CombineConfirm = false
      }
    })
    .onDrop(of: [.text], delegate: DragRelocateDelegate2(gridData: gridData))
    .overlay(self.gridData.isCombine ? AlertTwoButton(isPresented: $gridData.isCombine, confirm: $gridData.CombineConfirm) { Text("페이지를 합치시겠습니까?").font(.system(size: 16, weight: .regular))} : nil )

  }
}


func createImg(pages: [PageMO]) -> (imgs: [UIImage], model: [Grid]) {
  var model: [Grid] = []
  
  var imgs: [UIImage] = []
  for page in pages {
    if let monthly = page.monthly {
      let img = MonthlyDefaultView(monthly: monthly).asImage()
      let item = Grid(gridText: "\(page.objectID)", gridImg: img, gridPage: page)
      model.append(item)
      imgs.append(img)
    } else if let weekly = page.weekly {
      let img = WeeklyDefaultView(weekly: weekly).asImage()
      let item = Grid(gridText: "\(page.objectID)", gridImg: img, gridPage: page)
      model.append(item)
      imgs.append(img)
    } else if let daily = page.daily {
      let img = DailyViewOnPage(daily: daily).asImage()
      let item = Grid(gridText: "\(page.objectID)", gridImg: img, gridPage: page)
      model.append(item)
      imgs.append(img)
    } else if let memo = page.memo {
      let img = MemoView(memo: memo).asImage()
      let item = Grid(gridText: "\(page.objectID)", gridImg: img, gridPage: page)
      model.append(item)
      imgs.append(img)
    }
  }
  return (imgs, model)
}


