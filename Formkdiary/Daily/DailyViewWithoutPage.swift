//
//  DailyTest.swift
//  Formkdiary
//
//  Created by cch on 2022/09/20.
//

import SwiftUI
import CoreData

struct DailyViewWithoutPage: View {
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.managedObjectContext) private var viewContext
  @EnvironmentObject var keyboardManager: KeyboardManager
  
  @ObservedObject var daily: DailyMO
  
  var calendar: Calendar = CalendarModel.shared.calendar
  @StateObject var model: DailyMemoViewModel
  @State var isImagePicker: Bool = false

  
  let backgroundContext = PersistenceController.shared.backgroundContext
  var dailss: DailyMO {
    let fetchRequest = NSFetchRequest<DailyMO>(entityName: "Daily")
    fetchRequest.predicate = NSPredicate(format: "dailyId == %@", daily.dailyId as CVarArg)
    let result = try! backgroundContext.fetch(fetchRequest)
    let test = result.first!
    return test
  }
  
  init(daily: DailyMO) {
    self.daily = daily
    let model = DailyMemoViewModel()
    model.daily = daily
    _model = StateObject(wrappedValue: model)
  }
  
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

          .background(Color.customBg)
        
        
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
    } //geo
//    .ignoresSafeArea()
    .fullScreenCover(isPresented: $isImagePicker) {
      PhotoPicker(isPresented: $isImagePicker, model: model)
        .ignoresSafeArea()
        .tint(Color.customText)
    }
    .fullScreenCover(isPresented: $model.isImageDetail) {
      ImageSlider(model: model)
        .ignoresSafeArea()
    }
    .onChange(of: daily.text, perform: { newValue in
      backgroundContext.perform {
        daily.text = newValue
        do {
          try backgroundContext.save()
        } catch let error {
          print("@@@@@@@@@@@@@@@", error)
        }
      }
    })
    .onDisappear{
      if daily.text == "" {
        viewContext.delete(daily)
        CoreDataSave()
      }
    }
    
    .navigationTitle("\(calendar.component(.day, from: daily.date))")
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          presentationMode.wrappedValue.dismiss()
        } label: {
          Image(systemName: "chevron.left")
            .tint(Color.customIc)
        }
      }
    }//toolbar
  }
}
