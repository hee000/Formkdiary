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
        ForEach(Array(zip(gridData.gridItems.indices, gridData.gridItems)), id: \.1) { index, grid in
          if let _ = pages[index].monthly {
//            NavigationLink(destination: MonthlyDefaultView(id: monthly.objectID, in: viewContext)){
            NavigationLink(destination: PageView(note: note, pageIndex: index, pages: pages)){
              ZStack{
                Image(uiImage: grid.gridImg)
                .resizable()
                .frame(height: UIScreen.main.bounds.size.height/(CGFloat(Int(note.column)) + 1))
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
          else if let _ = pages[index].weekly {
//            NavigationLink(destination: WeeklyDefaultView(id: weeekly.objectID, in: viewContext)){
            NavigationLink(destination: PageView(note: note, pageIndex: index, pages: pages)){
              ZStack{
                Image(uiImage: grid.gridImg)
                .resizable()
                .frame(height: UIScreen.main.bounds.size.height/(CGFloat(Int(note.column)) + 1))
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

      } //lazyv
      .animation(.default, value: gridData.gridItems)
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
              let img = WeeklyDefaultView(id: weeekly.objectID, in: viewContext).asImage()
              let item = Grid(gridText: "\(page.objectID)", gridImg: img, gridPage: page)
              model.append(item)
              imgs.append(img)
            }
          }
          pageRenderImage = imgs
          gridData.gridItems = model
        }
      })
      .onChange(of: pages, perform: { new in
        DispatchQueue.main.async {
          var model: [Grid] = []

          var imgs: [UIImage] = []
          for page in new {
            if let monthly = page.monthly {
              let img = MonthlyDefaultView(id: monthly.objectID, in: viewContext).asImage()
              let item = Grid(gridText: "\(page.objectID)", gridImg: img, gridPage: page)
              model.append(item)
              imgs.append(img)
            } else if let weeekly = page.weekly {
              let img = WeeklyDefaultView(id: weeekly.objectID, in: viewContext).asImage()
              let item = Grid(gridText: "\(page.objectID)", gridImg: img, gridPage: page)
              model.append(item)
              imgs.append(img)
            }
          }
          pageRenderImage = imgs
          gridData.gridItems = model
        }
      })

      .padding()
      
    } //scroll
    .onDrop(of: [.text], delegate: DragRelocateDelegate2(gridData: gridData))
  }
}



