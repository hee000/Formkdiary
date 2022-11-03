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
}

enum Route: Hashable {
    case note(NoteMO)
    case page(PageMO)
    case daily(DailyMO)
}

class Navigator: ObservableObject {
  @Published var path = [Route]()
  @Published var page: PageMO? = nil
  @Published var note: NoteMO? = nil
}

struct ContentView: View {
  @Environment(\.colorScheme) var systemColorScheme
  @EnvironmentObject var navigator: Navigator
  
  @AppStorage("DarkMode") var darkMode: Bool = UserDefaults.standard.bool(forKey: "DarkMode")
  
  var body: some View {
    NavigationStack(path: $navigator.path) {
      MainView()
      //        .border(.black)
        .navigationDestination(for: Route.self, destination: { route in
          
          switch route {
          case let .note(note):
            NoteView(note: note)
          case let .page(page):
            PageView(note: page.note!, pageIndex: page.index)
          case let .daily(daily):
            DailyViewWithoutPage(daily: daily)
          }
        })
    }
    
//    .navigationViewStyle(StackNavigationViewStyle())
    .environmentObject(KeyboardManager())
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
