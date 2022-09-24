//
//  PageSelectView.swift
//  Formkdiary
//
//  Created by cch on 2022/07/01.
//

import SwiftUI
import CoreData


struct Grid: Identifiable, Hashable, Equatable {
  var id = UUID().uuidString
  var gridText: String
  var gridImg: UIImage
  var gridPage: PageMO
}

class GridViewModel: ObservableObject{
  @Published var gridItems: [Grid] = []
    @Published var currentGrid: Grid?
  @Published var currentGridOverlay: Grid?
}

struct PageSelectView: View {
  @Environment(\.managedObjectContext) private var viewContext

  @ObservedObject var note: NoteMO
  var pages: [PageMO]

  @ViewBuilder
  func imgEffect(img: UIImage, column: Int16, page: PageMO, titleVisible: Bool, isDrag: Bool) -> some View {
    ZStack{
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
              for i in page.note!.pages {
//                print("be", (i as! PageMO).index)
                (i as! PageMO).index -= 1
//                print("af", (i as! PageMO).index)
              }
              viewContext.delete(page)
              CoreDataSave()
              print("삭제")
            } label: {
                Label("Delete", systemImage: "trash.fill")
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
  }
  
  let columns = [
      GridItem(.flexible(), spacing: 15),
      GridItem(.flexible(), spacing: 15),
      GridItem(.flexible(), spacing: 15),
      GridItem(.flexible(), spacing: 15),
      GridItem(.flexible(), spacing: 15),
      GridItem(.flexible(), spacing: 15)
      ]
  
  @StateObject var gridData = GridViewModel()
  
  @State var pageRenderImage: [UIImage] = []
                    
  @State private var dragging: PageMO?
  
  var body: some View {
    ScrollView{
      LazyVGrid(columns: Array(columns[0 ..< Int(note.column)]), spacing: 15){
//        ForEach(Array(zip(gridData.gridItems.indices, gridData.gridItems)), id: \.1) { index, grid in
        ForEach(Array(zip(pages.indices, gridData.gridItems)), id: \.1) { index, grid in
          let page = pages[index]
          if let _ = page.monthly {
//            NavigationLink(destination: MonthlyDefaultView(id: monthly.objectID, in: viewContext)){
            NavigationLink(destination: PageView(note: note, pageIndex: index, pages: pages)){
//              ZStack{
//                VStack{
//                  imgEffect(img: grid.gridImg, column: note.column)
//                    .contextMenu {
//                      Button(role: .destructive) {
//                        viewContext.delete(page)
//                        CoreDataSave()
//                        print("삭제")
//                      } label: {
//                          Label("Delete", systemImage: "trash.fill")
//                      }
//                    }
//
//                  if note.titleVisible {
//                    Text(page.title)
//                      .font(.system(size: 10, weight: .regular))
//                      .lineLimit(1)
//                  }
//                }
//                if gridData.currentGrid == grid {
//                  Color.black.opacity(0.2)
//                    .cornerRadius(5)
//                }
//              }
              imgEffect(img: grid.gridImg, column: note.column, page: page, titleVisible: note.titleVisible, isDrag: gridData.currentGrid == grid)
              
            }
            
            .onDrag {
              gridData.currentGrid = grid
//              gridData.currentGridOverlay = grid
              return NSItemProvider(object: grid.gridText as NSString)
            }
            .onDrop(of: [.text], delegate: DragRelocateDelegate(grid: grid, gridData: gridData))

          } else if let _ = page.weekly {
            NavigationLink(destination: PageView(note: note, pageIndex: index, pages: pages)){
//              ZStack{
//                VStack{
//                  imgEffect(img: grid.gridImg, column: note.column)
//                    .contextMenu {
//                      Button(role: .destructive) {
//                        viewContext.delete(page)
//                        CoreDataSave()
//                        print("삭제")
//                      } label: {
//                          Label("Delete", systemImage: "trash.fill")
//                      }
//                    }
//
//                  if note.titleVisible {
//                    Text(page.title)
//                      .font(.system(size: 10, weight: .regular))
//                      .lineLimit(1)
//                  }
//                }
//                if gridData.currentGrid == grid {
//                  Color.black.opacity(0.2)
//                  .cornerRadius(5)
//                }
//              }
              imgEffect(img: grid.gridImg, column: note.column, page: page, titleVisible: note.titleVisible, isDrag: gridData.currentGrid == grid)
            }

            .onDrag {
              gridData.currentGrid = grid
              return NSItemProvider(object: grid.gridText as NSString)
            }
            .onDrop(of: [.text], delegate: DragRelocateDelegate(grid: grid, gridData: gridData))
          } else if let _ = page.daily {
            NavigationLink(destination: PageView(note: note, pageIndex: index, pages: pages)){
//              ZStack{
//                VStack{
//                  imgEffect(img: grid.gridImg, column: note.column)
//                    .contextMenu {
//                      Button(role: .destructive) {
//                        viewContext.delete(page)
//                        CoreDataSave()
//                        print("삭제")
//                      } label: {
//                          Label("Delete", systemImage: "trash.fill")
//                      }
//                    }
//
//                  if note.titleVisible {
//                    Text(page.title)
//                      .font(.system(size: 10, weight: .regular))
//                      .lineLimit(1)
//                  }
//                }
//                if gridData.currentGrid == grid {
//                  Color.black.opacity(0.2)
//                  .cornerRadius(5)
//                }
//              }
              imgEffect(img: grid.gridImg, column: note.column, page: page, titleVisible: note.titleVisible, isDrag: gridData.currentGrid == grid)
            }

            .onDrag {
              gridData.currentGrid = grid
              return NSItemProvider(object: grid.gridText as NSString)
            }
            .onDrop(of: [.text], delegate: DragRelocateDelegate(grid: grid, gridData: gridData))
          }
          else if let _ = page.memo {
            NavigationLink(destination: PageView(note: note, pageIndex: index, pages: pages)){
//              ZStack{
//                VStack{
//                  imgEffect(img: grid.gridImg, column: note.column)
//                    .contextMenu {
//                      Button(role: .destructive) {
//                        viewContext.delete(page)
//                        CoreDataSave()
//                        print("삭제")
//                      } label: {
//                          Label("Delete", systemImage: "trash.fill")
//                      }
//                    }
//
//                  if note.titleVisible {
//                    Text(page.title)
//                      .font(.system(size: 10, weight: .regular))
//                      .lineLimit(1)
//                  }
//                }
//                if gridData.currentGrid == grid {
//                  Color.black.opacity(0.2)
//                  .cornerRadius(5)
//                }
//              }
              imgEffect(img: grid.gridImg, column: note.column, page: page, titleVisible: note.titleVisible, isDrag: gridData.currentGrid == grid)
            }

            .onDrag {
              gridData.currentGrid = grid
              return NSItemProvider(object: grid.gridText as NSString)
            }
            .onDrop(of: [.text], delegate: DragRelocateDelegate(grid: grid, gridData: gridData))
          }

        } //for

      } //lazyv
      .animation(.default, value: gridData.gridItems)
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

      .padding()
      
    } //scroll
    .onDrop(of: [.text], delegate: DragRelocateDelegate2(gridData: gridData))
  }
}


func createImg(pages: [PageMO]) -> (imgs: [UIImage], model: [Grid]) {
  var model: [Grid] = []
  
  var imgs: [UIImage] = []
  for page in pages {
    if let monthly = page.monthly {
      let img = MonthlyDefaultView(_monthly: monthly).asImage()
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


