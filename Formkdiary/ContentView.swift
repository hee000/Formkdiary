//
//  ContentView.swift
//  Formkdiary
//
//  Created by cch on 2022/06/23.
//

import SwiftUI
import CoreData


func CoreDataSave() {
  do {
    try PersistenceController.shared.container.viewContext.save()
  } catch {
    let nsError = error as NSError
    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
  }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()


struct ContentView: View {
  
  var body: some View {
    
    MainView()
    
  }
}

