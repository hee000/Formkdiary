//
//  DragDrop.swift
//  Formkdiary
//
//  Created by hee on 2022/10/22.
//

import Foundation
import SwiftUI

struct PageGridDrag: DropDelegate {
  let page: PageMO
  var model: PageGridModel
  
  func validateDrop(info: DropInfo) -> Bool {
    return true
  }

  func dropEntered(info: DropInfo) {
    print("dd")
    let point = info.location.x
    
    let leftSide = model.gridOuterSize.width - model.gridInnerSize.width
    let rightSide = model.gridInnerSize.width
    
    let toIndex = model.pages.firstIndex { (pageMO) -> Bool in
        return pageMO.objectID == self.page.objectID
    } ?? 0
  
    if point < leftSide {
      model.gridMoveIndex = toIndex
      model.gridMove = .left
    } else if rightSide < point {
      model.gridMoveIndex = toIndex
      model.gridMove = .right
    } else {
      model.gridMove = .none
    }
  }

  func dropUpdated(info: DropInfo) -> DropProposal? {
    if page.objectID == model.currentPage?.objectID {
      model.gridMove = .none
      return DropProposal(operation: .move)
    }

    let point = info.location.x
    
    let leftSide = model.gridOuterSize.width - model.gridInnerSize.width
    let rightSide = model.gridInnerSize.width
    
//    var fromIndex = gridData.gridItems.firstIndex { (grid) -> Bool in
//        return grid.id == gridData.currentGrid?.id
//    } ?? 0
    
    let toIndex = model.pages.firstIndex { (pageMO) -> Bool in
        return pageMO.objectID == self.page.objectID
    } ?? 0
  
    if point < leftSide {
      model.gridMoveIndex = toIndex
      model.gridMove = .left
    } else if rightSide < point {
      model.gridMoveIndex = toIndex
      model.gridMove = .right
    } else {
      if let toMontly = model.pages[toIndex].monthly {
        if let fromWeekly = model.currentPage?.weekly {
          if CalendarModel.shared.calendar.isDate(fromWeekly.date, equalTo: toMontly.date, toGranularity: .month) {
            model.gridMove = .none
            return DropProposal(operation: .copy)
          }
        } else if let fromDaily = model.currentPage?.daily {
          if CalendarModel.shared.calendar.isDate(fromDaily.date, equalTo: toMontly.date, toGranularity: .month) {
            model.gridMove = .none
            return DropProposal(operation: .copy)
          }
        }
        
      } else if let toWeekly = model.pages[toIndex].weekly {
        if let fromDaily = model.currentPage?.daily {
          if CalendarModel.shared.calendar.isDate(fromDaily.date, equalTo: toWeekly.date, toGranularity: .weekOfYear) {
            model.gridMove = .none
            return DropProposal(operation: .copy)
          }
        }
      }
      model.gridMove = .none
    }
    
    return DropProposal(operation: .move)
  }
  
  func dropExited(info: DropInfo) {
    model.gridMove = .none
  }

  func performDrop(info: DropInfo) -> Bool {
    if page.objectID == model.currentPage?.objectID {
      model.currentPage = nil
      return true
    }
    
    let point = info.location.x
    
    let leftSide = model.gridOuterSize.width - model.gridInnerSize.width
    let rightSide = model.gridInnerSize.width
    
    var fromIndex = model.pages.firstIndex { (pageMO) -> Bool in
      return pageMO.objectID == self.model.currentPage?.objectID
    } ?? 0

    var toIndex = model.pages.firstIndex { (pageMO) -> Bool in
        return pageMO.objectID == self.page.objectID
    } ?? 0
    
    model.gridMove = .none
    
    if point < leftSide {
      let element = model.pages.remove(at: fromIndex)
      if fromIndex < toIndex {
        toIndex -= 1
      }
      model.pages.insert(element, at: toIndex)
      
    } else if rightSide < point {
      let element = model.pages.remove(at: fromIndex)
      if fromIndex < toIndex {
        toIndex -= 1
      }
      model.pages.insert(element, at: toIndex + 1)
    } else {
      if let toMontly = model.pages[toIndex].monthly {
        if let fromWeekly = model.currentPage?.weekly { // 먼-위
          if CalendarModel.shared.calendar.isDate(fromWeekly.date, equalTo: toMontly.date, toGranularity: .month) {
            let combinePage = CombinePage(fromPage: fromWeekly.page, toPage: toMontly.page)
            model.combinePage = combinePage
            model.isCombine = true
          }
        } else if let fromDaily = model.currentPage?.daily { // 먼-데
          if CalendarModel.shared.calendar.isDate(fromDaily.date, equalTo: toMontly.date, toGranularity: .month) {
            let combinePage = CombinePage(fromPage: fromDaily.page, toPage: toMontly.page)
            model.combinePage = combinePage
            model.isCombine = true
          }
        }
        
      } else if let toWeekly = model.pages[toIndex].weekly {
        if let fromDaily = model.currentPage?.daily { // 위-데
          if CalendarModel.shared.calendar.isDate(fromDaily.date, equalTo: toWeekly.date, toGranularity: .weekOfYear) {
            let combinePage = CombinePage(fromPage: fromDaily.page, toPage: toWeekly.page)
            model.combinePage = combinePage
            model.isCombine = true
          }
        }
      }
      
      model.currentPage = nil
      return true
    }
    
    for (idx, page) in model.pages.enumerated() {
      page.index = Int32(idx)
    }
    
    CoreDataSave()
    //To never disappear drag item when dropped outside
    model.currentPage = nil
    return true
  }
}

struct PageListDrag: DropDelegate {
  let page: PageMO
  var model: PageListModel
  
  func validateDrop(info: DropInfo) -> Bool {
//    print(model.currentPage?.title)
    return true
    }

  func dropEntered(info: DropInfo) {
      print("드롭핑")
//      print(page.title)
    }

  func dropUpdated(info: DropInfo) -> DropProposal? {
    if page.objectID == model.currentPage?.objectID {
      return DropProposal(operation: .move)
    }
    
    let toIndex = model.pages.firstIndex { (pageMO) -> Bool in
      return pageMO.objectID == self.page.objectID
    } ?? 0
    
    
    if let toMontly = model.pages[toIndex].monthly {
      if let fromWeekly = model.currentPage?.weekly {
        if CalendarModel.shared.calendar.isDate(fromWeekly.date, equalTo: toMontly.date, toGranularity: .month) {
          return DropProposal(operation: .copy)
        }
      } else if let fromDaily = model.currentPage?.daily {
        if CalendarModel.shared.calendar.isDate(fromDaily.date, equalTo: toMontly.date, toGranularity: .month) {
          return DropProposal(operation: .copy)
        }
      }
      
    } else if let toWeekly = model.pages[toIndex].weekly {
      if let fromDaily = model.currentPage?.daily {
        if CalendarModel.shared.calendar.isDate(fromDaily.date, equalTo: toWeekly.date, toGranularity: .weekOfYear) {
          return DropProposal(operation: .copy)
        }
      }
    }
    
    return DropProposal(operation: .move)
  }
  
  func dropExited(info: DropInfo) {

  }

  func performDrop(info: DropInfo) -> Bool {
    if page.objectID == model.currentPage?.objectID {
      model.currentPage = nil
      return true
    }

//    model.pages.first { PageMO in
//      print("ddddd")
//      return true
//    }
    
//    var fromIndex = model.pages.firstIndex { (pageMO) -> Bool in
//      return pageMO.objectID == self.page.objectID
//    } ?? 0

    let toIndex = model.pages.firstIndex { (pageMO) -> Bool in
      return pageMO.objectID == self.page.objectID
    } ?? 0
    

    if let toMontly = model.pages[toIndex].monthly {
      if let fromWeekly = model.currentPage?.weekly { // 먼-위
        if CalendarModel.shared.calendar.isDate(fromWeekly.date, equalTo: toMontly.date, toGranularity: .month) {
          let combinePage = CombinePage(fromPage: fromWeekly.page, toPage: toMontly.page)
          model.combinePage = combinePage
          model.isCombine = true
        }
      } else if let fromDaily = model.currentPage?.daily { // 먼-데
        if CalendarModel.shared.calendar.isDate(fromDaily.date, equalTo: toMontly.date, toGranularity: .month) {
          let combinePage = CombinePage(fromPage: fromDaily.page, toPage: toMontly.page)
          model.combinePage = combinePage
          model.isCombine = true
        }
      }

    } else if let toWeekly = model.pages[toIndex].weekly {
      if let fromDaily = model.currentPage?.daily { // 위-데
        if CalendarModel.shared.calendar.isDate(fromDaily.date, equalTo: toWeekly.date, toGranularity: .weekOfYear) {
          let combinePage = CombinePage(fromPage: fromDaily.page, toPage: toWeekly.page)
          model.combinePage = combinePage
          model.isCombine = true
        }
      }
    }
    
    model.currentPage = nil
    return true
  }
}


struct DragRelocateDelegate: DropDelegate {
  let grid: Grid
  var gridData: GridViewModel
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
