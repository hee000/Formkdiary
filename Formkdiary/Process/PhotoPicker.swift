//
//  PhotoPicker.swift
//  Formkdiary
//
//  Created by hee on 2022/10/27.
//

import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
  @Binding var isPresented: Bool
  @ObservedObject var model: DailyMemoViewModel
  func makeUIViewController(context: Context) -> PHPickerViewController {
    var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
    configuration.selectionLimit = 5

    let controller = PHPickerViewController(configuration: configuration)
    controller.delegate = context.coordinator
    return controller
  }
  func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  // Use a Coordinator to act as your PHPickerViewControllerDelegate
  class Coordinator: PHPickerViewControllerDelegate {
    
    private let parent: PhotoPicker
    
    init(_ parent: PhotoPicker) {
      self.parent = parent
    }
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
      
      if results.isEmpty {
        parent.isPresented = false
        return
      }
      
      let itemProviders = results.map(\.itemProvider)
      
      var newImageArrray = [UIImage]()
      
      let waitGroup = DispatchGroup()
      
      PageLoadingQueue.sync {
        for itemProvider in itemProviders {
          if itemProvider.canLoadObject(ofClass: UIImage.self) {
            waitGroup.enter()
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
              if let image = image as? UIImage {
//                self.parent.model.images.append(image)
                newImageArrray.append(image)
//                print("111111")
                waitGroup.leave()
              } else {
                print("Could not load image", error?.localizedDescription ?? "")
              }
            }
          }
        }
      }
      
      waitGroup.notify(queue: .main) {
//        print("2222222222")
        self.parent.model.images.append(contentsOf: newImageArrray)
        waitGroup.notify(queue: .global(qos: .background)) {
//          print("333")
          self.parent.model.saveImage()
        }
      }
      
      parent.isPresented = false // Set isPresented to false because picking has finished.
    }
  }
}

