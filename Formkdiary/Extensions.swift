//
//  extensions.swift
//  Formkdiary
//
//  Created by cch on 2022/07/01.
//

import Foundation
import SwiftUI
import UIKit


extension Date {
    
    func toString( dateFormat format: String ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: self)
    }
    
    func toStringKST( dateFormat format: String ) -> String {
        return self.toString(dateFormat: format)
    }
    
    func toStringUTC( dateFormat format: String ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: self)
    }
}


extension NSSet {
//  func toArray<T>() -> [T] {
//    let array = self.map({ $0 as! T})
//    return array
//  }
  
  func toArray<T>() -> [T] {
    return self.allObjects as! [T]
  }
}


extension UINavigationController: ObservableObject, UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

extension View {
    func asImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        
        // locate far out of screen
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        
        
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        UIApplication.shared.windows.first?.rootViewController?.view.addSubview(controller.view)
        
        let image = controller.view.asImage()
        controller.view.removeFromSuperview()
        return image
    }
}

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
      
        return renderer.image { rendererContext in
// [!!] Uncomment to clip resulting image
//             rendererContext.cgContext.addPath(
//                UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath)
//            rendererContext.cgContext.clip()

//            DispatchQueue.main.sync {
              self.layer.render(in: rendererContext.cgContext)
//            }
        }
    }
}


//DispatchQueue.main.async {
//  dormis.data = restdata
//}

extension UIPickerView {
   open override var intrinsicContentSize: CGSize {
      return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)}
}



//struct DragRelocateDelegate: DropDelegate {
//    let item: PageMO
//    @Binding var listData: [PageMO]
//    @Binding var listImg: [UIImage]
//    @Binding var current: PageMO?
//
//
//    func dropEntered(info: DropInfo) {
//        if item != current {
//
//
//          let from = listData.firstIndex(of: current!)!
//          let to = listData.firstIndex(of: item)!
//
//
//          if listImg[to] != current! {
//
////            let tmp = listData[from].index
////
////            listData[from].index = Int16(to > from ? to + 1 : to)
////            listData[to].index = tmp
//
////                let fromGrid = gridData.gridItems[fromIndex]
////                gridData.gridItems[fromIndex] = gridData.gridItems[toIndex]
////                gridData.gridItems[toIndex] = fromGrid
//              listImg.move(fromOffsets: IndexSet(integer: from),
//                      toOffset: to > from ? to + 1 : to)
//
//
////            listImg.move(fromOffsets: IndexSet(integer: from),
////                    toOffset: to > from ? to + 1 : to)
//          }
//        }
//    }
//
//    func dropUpdated(info: DropInfo) -> DropProposal? {
//        return DropProposal(operation: .move)
//    }
//
//    func performDrop(info: DropInfo) -> Bool {
//      print("aaaaaaaaaaa")
//      CoreDataSave()
//        self.current = nil
//        return true
//    }
//}


struct DragRelocateDelegate: DropDelegate {
  let grid: Grid
  var gridData: GridViewModel
  @State var index = 0
//  @Binding var gridz : Grid
  
//  init(grid: Grid, gridData: GridViewModel, gridz: BiGrid) {
//    self.grid = grid
//    self.gridData = gridData
//    self._gridz = gridz
//  }
  
  func validateDrop(info: DropInfo) -> Bool {
//    print("223232323232")
    return true
    }

  func dropEntered(info: DropInfo) {
//      print("드롭핑")
    let point = info.location.x
    
    let leftSide = gridData.gridOuterSize.width - gridData.gridInnerSize.width
    let rightSide = gridData.gridInnerSize.width
    
//      let fromIndex = gridData.gridItems.firstIndex { (grid) -> Bool in
//          return grid.id == gridData.currentGrid?.id
//      } ?? 0
//
    let toIndex = gridData.gridItems.firstIndex { (grid) -> Bool in
        return grid.id == self.grid.id
    } ?? 0
  
    if point < leftSide {
      gridData.gridItems[toIndex].gridMove = .left
    } else if rightSide < point {
      gridData.gridItems[toIndex].gridMove = .right
    } else {
      gridData.gridItems[toIndex].gridMove = .none
    }

//      if fromIndex != toIndex{
////          withAnimation(.default){
////              let fromGrid = gridData.gridItems[fromIndex]
////              gridData.gridItems[fromIndex] = gridData.gridItems[toIndex]
////              gridData.gridItems[toIndex] = fromGrid
//            print("읻겟스 바꿈")
//            gridData.gridItems.move(fromOffsets: IndexSet(integer: fromIndex),
//                      toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
////          }
//        for (idx, item) in gridData.gridItems.enumerated() {
//          item.gridPage.index = Int32(idx)
//        }
//      }

//      print(grid.id)
    }

  func dropUpdated(info: DropInfo) -> DropProposal? {
    if grid.id == gridData.currentGrid?.id {
      return DropProposal(operation: .move)
    }

    let point = info.location.x
    
    let leftSide = gridData.gridOuterSize.width - gridData.gridInnerSize.width
    let rightSide = gridData.gridInnerSize.width
    
//    var fromIndex = gridData.gridItems.firstIndex { (grid) -> Bool in
//        return grid.id == gridData.currentGrid?.id
//    } ?? 0
    
    let toIndex = gridData.gridItems.firstIndex { (grid) -> Bool in
        return grid.id == self.grid.id
    } ?? 0
  
    if point < leftSide {
      gridData.gridItems[toIndex].gridMove = .left
    } else if rightSide < point {
      gridData.gridItems[toIndex].gridMove = .right
    } else {
      if let toMontly = gridData.gridItems[toIndex].gridPage.monthly {
        if let fromWeekly = gridData.currentGrid?.gridPage.weekly {
          if CalendarModel.shared.calendar.isDate(fromWeekly.date, equalTo: toMontly.date, toGranularity: .month) {
            return DropProposal(operation: .copy)
          }
        } else if let fromDaily = gridData.currentGrid?.gridPage.daily {
          if CalendarModel.shared.calendar.isDate(fromDaily.date, equalTo: toMontly.date, toGranularity: .month) {
            return DropProposal(operation: .copy)
          }
        }
        
      } else if let toWeekly = gridData.gridItems[toIndex].gridPage.weekly {
        if let fromDaily = gridData.currentGrid?.gridPage.daily {
          if CalendarModel.shared.calendar.isDate(fromDaily.date, equalTo: toWeekly.date, toGranularity: .weekOfYear) {
            return DropProposal(operation: .copy)
          }
        }
      }
      gridData.gridItems[toIndex].gridMove = .none
    }
    
    return DropProposal(operation: .move)
  }
  
  func dropExited(info: DropInfo) {
    let toIndex = gridData.gridItems.firstIndex { (grid) -> Bool in
        return grid.id == self.grid.id
    } ?? 0
    
    gridData.gridItems[toIndex].gridMove = .none
  }

  func performDrop(info: DropInfo) -> Bool {
    if grid.id == gridData.currentGrid?.id {
      gridData.currentGrid = nil
      return true
    }
    
    let point = info.location.x
    
    let leftSide = gridData.gridOuterSize.width - gridData.gridInnerSize.width
    let rightSide = gridData.gridInnerSize.width
    
    var fromIndex = gridData.gridItems.firstIndex { (grid) -> Bool in
        return grid.id == gridData.currentGrid?.id
    } ?? 0

    var toIndex = gridData.gridItems.firstIndex { (grid) -> Bool in
        return grid.id == self.grid.id
    } ?? 0
    
    gridData.gridItems[toIndex].gridMove = .none
    
    if point < leftSide {
      let element = gridData.gridItems.remove(at: fromIndex)
      if fromIndex < toIndex {
        toIndex -= 1
      }
      gridData.gridItems.insert(element, at: toIndex)
      
    } else if rightSide < point {
      let element = gridData.gridItems.remove(at: fromIndex)
      if fromIndex < toIndex {
        toIndex -= 1
      }
      gridData.gridItems.insert(element, at: toIndex + 1)
    } else {
      if let toMontly = gridData.gridItems[toIndex].gridPage.monthly {
        if let fromWeekly = gridData.currentGrid?.gridPage.weekly { // 먼-위
          if CalendarModel.shared.calendar.isDate(fromWeekly.date, equalTo: toMontly.date, toGranularity: .month) {
            let combinePage = CombinePage(fromPage: fromWeekly.page, toPage: toMontly.page)
            gridData.combinePage = combinePage
            gridData.isCombine = true
          }
        } else if let fromDaily = gridData.currentGrid?.gridPage.daily { // 먼-데
          if CalendarModel.shared.calendar.isDate(fromDaily.date, equalTo: toMontly.date, toGranularity: .month) {
            let combinePage = CombinePage(fromPage: fromDaily.page, toPage: toMontly.page)
            gridData.combinePage = combinePage
            gridData.isCombine = true
          }
        }
        
      } else if let toWeekly = gridData.gridItems[toIndex].gridPage.weekly {
        if let fromDaily = gridData.currentGrid?.gridPage.daily { // 위-데
          if CalendarModel.shared.calendar.isDate(fromDaily.date, equalTo: toWeekly.date, toGranularity: .weekOfYear) {
            let combinePage = CombinePage(fromPage: fromDaily.page, toPage: toWeekly.page)
            gridData.combinePage = combinePage
            gridData.isCombine = true
          }
        }
      }
      
      gridData.currentGrid = nil
      return true
    }
    
    for (idx, item) in gridData.gridItems.enumerated() {
      item.gridPage.index = Int32(idx)
    }
    
    CoreDataSave()
    //To never disappear drag item when dropped outside
    gridData.currentGrid = nil
    return true
  }
}



struct DragRelocateDelegate2: DropDelegate {
    var gridData: GridViewModel
  
  func validateDrop(info: DropInfo) -> Bool {

    return true
    }

    func dropEntered(info: DropInfo) {
//      print("들감")
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
//      print("업뎃")
        return DropProposal(operation: .move)
    }
  
  func dropExited(info: DropInfo) {

  }

    func performDrop(info: DropInfo) -> Bool {
      gridData.currentGrid = nil
        return true
    }
}
