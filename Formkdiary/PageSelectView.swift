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

  var pages: [PageMO] 
  
  let columns = [
      GridItem(.flexible(), spacing: 15),
      GridItem(.flexible(), spacing: 15),
      GridItem(.flexible(), spacing: 15),
      GridItem(.flexible(), spacing: 15),
      GridItem(.flexible(), spacing: 15)
      ]
  
  @StateObject var gridData = GridViewModel()
//  @ObservedObject var im
  
  
  @State var pageRenderImage: [UIImage] = []
                    
  @State private var dragging: PageMO?
  
  @AppStorage("Setting-column") var columnSetting: Int = (UserDefaults.standard.integer(forKey: "Setting-column") != 0) ? UserDefaults.standard.integer(forKey: "Setting-column") : 2

  var body: some View {
    ScrollView{

//      LazyVGrid(columns: columns[..<option.sel], spacing: 15){
      LazyVGrid(columns: Array(columns[0 ..< columnSetting]), spacing: 15){
        ForEach(Array(zip(gridData.gridItems.indices, gridData.gridItems)), id: \.1) { index, grid in
          if let monthly = pages[index].monthly {
//            NavigationLink(destination: MonthlyDefaultView(id: monthly.objectID, in: viewContext)){
            NavigationLink(destination: PageView(pageIndex: index, pages: pages)){
              ZStack{
                Image(uiImage: grid.gridImg)
//                Image(uiImage: PageViewImageLoader(view: PageView(pageIndex: index, pages: pages)).image)
//                Image(uiImage: ImageRenderer(content: PageView(pageIndex: index, pages: pages)).uiImage!)
//                Image(
                .resizable()
                .frame(height: UIScreen.main.bounds.size.height/4)
                .background(Color.white)
                .cornerRadius(5)
                .clipped()
                .shadow(color: Color.black.opacity(0.2), radius: 2)
                if gridData.currentGrid == grid {
                  Color.black.opacity(0.2)
                    .cornerRadius(5)
                }
              }
            }
            .onDrag {
              gridData.currentGrid = grid
//              gridData.currentGridOverlay = grid
              return NSItemProvider(object: grid.gridText as NSString)
            }
            .onDrop(of: [.text], delegate: DragRelocateDelegate(grid: grid, gridData: gridData))

          }
          else if let weeekly = pages[index].weekly {

            NavigationLink(destination: WeeeklyDefaultView(id: weeekly.objectID, in: viewContext)){
              ZStack{
                Image(uiImage: grid.gridImg)
                .resizable()
                .frame(height: UIScreen.main.bounds.size.height/4)
                .background(Color.white)
                .cornerRadius(5)
                .clipped()
                .shadow(color: Color.black.opacity(0.2), radius: 2)
                if gridData.currentGrid == grid {
                  Color.black.opacity(0.2)
                  .cornerRadius(5)
                }
              }
            }

            .onDrag {
              gridData.currentGrid = grid
              return NSItemProvider(object: grid.gridText as NSString)
            }
            .onDrop(of: [.text], delegate: DragRelocateDelegate(grid: grid, gridData: gridData))
          }

        } //for
        .frame(height: UIScreen.main.bounds.size.height/4)
        

//        ForEach(pageRenderImage.indices, id:\.self) { index in
//          if let monthly = pages[index].monthly {
//
//            NavigationLink(destination: MonthlyDefaultView(id: monthly.objectID, in: viewContext)){
//              Image(uiImage: pageRenderImage[index])
//              .resizable()
//              .frame(height: UIScreen.main.bounds.size.height/4)
//              .background(Color.white)
//              .cornerRadius(5)
//              .clipped()
//              .shadow(color: Color.black.opacity(0.2), radius: 2)
//            }
//            .id(pages[index].objectID)
//            .onDrag {
//              self.dragging = pages[index]
//              return NSItemProvider(object: String("\(pages[index].objectID)") as NSString) }
//            .onDrop(of: [.text], delegate: DragRelocateDelegate(item: pages[index], listData: $pages, listImg: $pageRenderImage, current: $dragging))
//            .overlay(dragging == pages[index] ? Color.white.opacity(0.6) : Color.clear)
//
//          } else if let weeekly = pages[index].weeekly {
//
//            NavigationLink(destination: WeeeklyDefaultView(id: weeekly.objectID, in: viewContext)){
//              Image(uiImage: pageRenderImage[index])
//              .resizable()
//              .frame(height: UIScreen.main.bounds.size.height/4)
//              .background(Color.white)
//              .cornerRadius(5)
//              .clipped()
//              .shadow(color: Color.black.opacity(0.2), radius: 2)
//            }
//            .id(pages[index].objectID)
//            .onDrag {
//              self.dragging = pages[index]
//              return NSItemProvider(object: String("\(pages[index].objectID)") as NSString) }
//            .onDrop(of: [.text], delegate: DragRelocateDelegate(item: pages[index], listData: $pages, listImg: $pageRenderImage, current: $dragging))
//            .overlay(dragging == pages[index] ? Color.white.opacity(0.6) : Color.clear)
//          }
//
//        } //for
//        .frame(height: UIScreen.main.bounds.size.height/4)

      } //lazyv
//      .onDrop(of: [.text], delegate: DragRelocateDelegate2(gridData: gridData))
      .animation(.default, value: gridData.gridItems)
//      .animation(.default)
      .onAppear(perform: {
        DispatchQueue.main.async {
          var model: [Grid] = []
          
          var imgs: [UIImage] = []
          for page in pages {
            if let monthly = page.monthly {
              let img = MonthlyDefaultView(id: monthly.objectID, in: viewContext).asImage()
              let item = Grid(gridText: "\(page.objectID)", gridImg: img, gridPage: page)
              model.append(item)
              imgs.append(img)
            } else if let weeekly = page.weekly {
              let img = WeeeklyDefaultView(id: weeekly.objectID, in: viewContext).asImage()
              let item = Grid(gridText: "\(page.objectID)", gridImg: img, gridPage: page)
              model.append(item)
              imgs.append(img)
            }
          }
          pageRenderImage = imgs
          gridData.gridItems = model
        }
      })
//      .onChange(of: pages, perform: { new in
//        DispatchQueue.main.async {
//          var model: [Grid] = []
//
//          var imgs: [UIImage] = []
//          for page in new {
//            if let monthly = page.monthly {
//              let img = MonthlyDefaultView(id: monthly.objectID, in: viewContext).asImage()
//              let item = Grid(gridText: "\(page.objectID)", gridImg: img, gridPage: page)
//              model.append(item)
//              imgs.append(img)
//            } else if let weeekly = page.weeekly {
//              let img = WeeeklyDefaultView(id: weeekly.objectID, in: viewContext).asImage()
//              let item = Grid(gridText: "\(page.objectID)", gridImg: img, gridPage: page)
//              model.append(item)
//              imgs.append(img)
//            }
//          }
//          pageRenderImage = imgs
//          gridData.gridItems = model
//        }
//      })

      .padding()
    } //scroll
    .onDrop(of: [.text], delegate: DragRelocateDelegate2(gridData: gridData))
    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    
  }
}



