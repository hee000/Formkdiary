//
//  FormkdiaryApp.swift
//  Formkdiary
//
//  Created by cch on 2022/06/23.
//

import SwiftUI

@main
struct FormkdiaryApp: App {
  let persistenceController = PersistenceController.shared

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}


let PageLoadingQueue = DispatchQueue(label: "page")


