//
//  ContentView.swift
//  Formkdiary
//
//  Created by cch on 2022/06/23.
//

import SwiftUI
import CoreData


func CoreDataSave() {
  PersistenceController.shared.save()
//  do {
//    try PersistenceController.shared.save()
//  } catch {
//    let nsError = error as NSError
//    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//  }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()


struct ContentView: View {
  @Environment(\.colorScheme) var systemColorScheme

  
  @AppStorage("DarkMode") var darkMode: Bool = UserDefaults.standard.bool(forKey: "DarkMode")
  
  var body: some View {
//    NavigationView{
      MainView()
//    }
    .navigationViewStyle(StackNavigationViewStyle())
    .environmentObject(PageNavi())
    .environmentObject(KeyboardManager())
    .environmentObject(SearchNavigator())
    .preferredColorScheme(darkMode ? .dark : .light)
//      .preferredColorScheme(systemColorScheme)
    .onAppear{
//        deleteAllEnt`ities()
    }

//    TEst()
  }
}


func deleteAllEntities() {
//    let entities = PersistenceController.shared.container.managedObjectModel.entities
//    for entity in entities {
//        delete(entityName: entity.name!)
//    }
}

func delete(entityName: String) {
//    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
//    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//    do {
//        try PersistenceController.shared.container.viewContext.execute(deleteRequest)
//    } catch let error as NSError {
//        debugPrint(error)
//    }
}
