//
//  FormkdiaryApp.swift
//  Formkdiary
//
//  Created by cch on 2022/06/23.
//

import SwiftUI

@main
struct FormkdiaryApp: App {
//  let persistenceController = PersistenceController.shared
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.context)
        .environmentObject(Navigator())
    }
  }
}


let PageLoadingQueue = DispatchQueue(label: "page")


