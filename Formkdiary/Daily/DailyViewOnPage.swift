//
//  DailyViewOnPage.swift
//  Formkdiary
//
//  Created by cch on 2022/09/24.
//

import SwiftUI
import CoreData
import CloudKit

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

class DailyMemoViewModel: ObservableObject {
  @Published var daily: DailyMO = DailyMO()
  @Published var titleVisible = false
  @Published var images: [UIImage] = []
  @Published var imageDetailIndex = 0
  @Published var isImageDetail = false
  var pickerImages: [UIImage] = []
  
  func loadImage(imageData: Data) {
    DispatchQueue.global(qos: .background).async {
      var newImageArray = [UIImage]()
      if let dataArray = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: imageData) {
        for data in dataArray {
          if let data = data as? Data, let image = UIImage(data: data) {
            newImageArray.append(image)
          }
        }
        //      print("DDDDDD", newImageArray)
        DispatchQueue.main.async {
          self.images = newImageArray
        }
      }
    }
  }
  
  func saveImage() {
    DispatchQueue.global(qos: .background).async {
      let dataArray = NSMutableArray()
      
      for img in self.images {
        
        if let data = img.pngData() {
          dataArray.add(data)
        }
      }
      
      guard let data: Data = try? NSKeyedArchiver.archivedData(withRootObject: dataArray, requiringSecureCoding: true)
      else { return }
      
      self.daily.images = data
      
      CoreDataSave()
    }
  }
  
}

struct DailyViewOnPage: View {
  @Environment(\.managedObjectContext) private var viewContext
  @EnvironmentObject var keyboardManager: KeyboardManager
  
  @ObservedObject var daily: DailyMO
//  let titleVisible: Bool
  
  @StateObject var model: DailyMemoViewModel
  
  @State var isImagePicker: Bool = false
//  @FocusState private var focus: Bool

  init(daily: DailyMO, titleVisible: Bool = false) {
    self.daily = daily
    
    let model = DailyMemoViewModel()
    model.daily = daily
    model.titleVisible = titleVisible
//    self.titleVisible = titleVisible
    _model = StateObject(wrappedValue: model)
    
  }
  
  let backgroundContext = PersistenceController.shared.backgroundContext
  var backDaily: DailyMO {
    let fetchRequest = NSFetchRequest<DailyMO>(entityName: "Daily")
    fetchRequest.predicate = NSPredicate(format: "dailyId == %@", daily.dailyId as CVarArg)
    let result = try! backgroundContext.fetch(fetchRequest)
    let test = result.first!
    return test
  }
  
  @State private var textStyle = UIFont.TextStyle.body
  
  var body: some View {
    GeometryReader { geo in
      VStack(spacing: 0) {
        if let imageData = daily.images {
          ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack{
              ForEach(Array(model.images.enumerated()), id:\.element) { index, image in
                Image(uiImage: image)
                  .resizable()
                  .scaledToFit()
                  .frame(width: keyboardManager.isVisible ? geo.size.height/5 : geo.size.height/6*2)
                  .onTapGesture {
                    hideKeyboard()
                    model.imageDetailIndex = index
                    model.isImageDetail.toggle()
                  }
              }
            }
          }
          .padding(.horizontal)
          .frame(height: model.images.isEmpty ? 0 : keyboardManager.isVisible ? geo.size.height/5 : geo.size.height/6*2)
          .onTapGesture {
            hideKeyboard()
          }
          .task {
            model.loadImage(imageData: imageData)
          }
        }
        
//            TextView(text: $daily.text, textStyle: $textStyle)
        TextEditor(text: $daily.text)
          .padding(.horizontal)
          .scrollContentBackground(.hidden) // <- Hide it
          .accentColor(Color.customText)
          .background(Color.customBg)
//          .edgesIgnoringSafeArea(keyboardManager.isVisible ? [] : .bottom)
        
        
        if keyboardManager.isVisible {
          HStack {
            Button{
              isImagePicker.toggle()
            } label: {
              Image(systemName: "photo")
                .foregroundColor(Color.customIc)
            }

            Spacer()

            Button{
              hideKeyboard()
            } label: {
              Image(systemName: "xmark")
                .foregroundColor(Color.customIc)
            }
          }
          .padding()
          .background(Color.customBg)
          .frame(height: 45)
        }
      }//v
    }// geo
    .fullScreenCover(isPresented: $isImagePicker) {
      PhotoPicker(isPresented: $isImagePicker, model: model)
        .ignoresSafeArea()
    }
    .fullScreenCover(isPresented: $model.isImageDetail) {
      ImageSlider(model: model)
        .ignoresSafeArea()
    }
    .onChange(of: daily.text, perform: { newValue in
      backgroundContext.perform {
        backDaily.text = newValue
        do {
          try backgroundContext.save()
        } catch let error {
          print("@@@@@@@@@@@@@@@", error)
        }
      }

    })

  }
}
