//
//  extensions.swift
//  Formkdiary
//
//  Created by cch on 2022/07/01.
//

import Foundation
import SwiftUI
import UIKit

extension String{
    func getArrayAfterRegex(regex: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Color {
  static let customBg = Color("gray_bg")
  static let customText = Color("gray_text")
  static let customTextLight = Color("gray_text_light")
  static let customIc = Color("gray_ic")
}


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

