////
////  NoteView.swift
////  Formkdiary
////
////  Created by cch on 2022/06/23.
////
//
//import SwiftUI
//import CoreData
//
//struct NoteView: View {
//  @Environment(\.presentationMode) var presentationMode
//  @Environment(\.managedObjectContext) private var viewContext
//
//  @FetchRequest(
//      sortDescriptors: [],
//      animation: .default)
//  var notes : FetchedResults<NoteMO>
////  @FetchRequest var note : FetchedResults<NoteMO>
//  @State var pageAdd = false
//  var noteId: UUID
//
////  init(noteId: UUID) {
////    self.noteId = noteId
////
////    var predicate = NSPredicate(format: "noteId == '\(self.noteId)'")
////
////    self._note = FetchRequest(entity: NoteMO.entity(), sortDescriptors: [], predicate: predicate, animation: .default)
////  }
//
//
//    var body: some View {
////      let note = notes.map{$0.noteId == self.noteId}
//      GeometryReader { geo in
//        VStack{
//        if notes.first?.pages.allObjects.count == 0 {
//          Text("페이지를 추가해주세요.")
//        } else {
//          if let pages = notes.first?.pages.allObjects as? [PageMO] {
//            ForEach(pages) { page in
//              if let monthly = page.monthly {
//                Text("\(monthly.monthlyId)")
//              }
//            }
//          }
//        }
//        }
//
//
//      } //geo
//      .fullScreenCover(isPresented: $pageAdd) {
//        PageAddView(noteId: noteId)
//      }
//
//      .navigationTitle(notes.first != nil ? notes.first!.title : "")
//      .navigationBarTitleDisplayMode(.inline)
//      .navigationBarBackButtonHidden(true)
//      .toolbar {
//        ToolbarItem(placement: .navigationBarLeading) {
//          Button {
//            presentationMode.wrappedValue.dismiss()
//          } label: {
//            Image(systemName: "chevron.left")
//              .foregroundColor(.black)
//          }
//        }
//        ToolbarItem(placement: .navigationBarTrailing) {
//          Button {
//            pageAdd.toggle()
//          } label: {
//            Image(systemName: "plus")
//              .foregroundColor(.black)
//          }
//        }
//      }//toolbar
//    }
//}
//
////struct NoteView_Previews: PreviewProvider {
////    static var previews: some View {
////        NoteView()
////    }
////}


//
//  NoteView.swift
//  Formkdiary
//
//  Created by cch on 2022/06/23.
//

import SwiftUI
import CoreData


struct NoteView: View {
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.managedObjectContext) private var viewContext
  
  @ObservedObject var note: NoteMO
  
  @State var pageAdd = false
  
  @FetchRequest var pages: FetchedResults<PageMO>

  init(id objectID: NSManagedObjectID, in context: NSManagedObjectContext) {
      if let note = try? context.existingObject(with: objectID) as? NoteMO {
          self.note = note
      } else {
          // if there is no object with that id, create new one
          self.note = NoteMO(context: context)
          try? context.save()
      }
    
    _pages = FetchRequest<PageMO>(sortDescriptors: [SortDescriptor(\.index)], predicate: NSPredicate(format: "%K == %@", #keyPath(PageMO.note), objectID))
  }
  
    var body: some View {
//      let note = notes.map{$0.noteId == self.noteId}
      GeometryReader { geo in
          VStack{
          if note.pages.count == 0 {
            Text("페이지를 추가해주세요.")
              .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
              
          } else {
//            if let pages = note.pages.allObjects.sorted(by: {($0 as! PageMO).index < ($1 as! PageMO).index}) as? [PageMO] {
//              PageSelectView(pages: pages)
//            }
            if let page = pages.map{ $0 } as? [PageMO] {
              PageSelectView(pages: page)
            }
          }
        }
      
        
      } //geo
      .fullScreenCover(isPresented: $pageAdd) {
        PageAddView(id: note.objectID, in: viewContext)
      }
      
      .navigationTitle(note.title)
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarBackButtonHidden(true)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            presentationMode.wrappedValue.dismiss()
          } label: {
            Image(systemName: "chevron.left")
              .foregroundColor(.black)
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          HStack {
            Button {
              pageAdd.toggle()
            } label: {
              Image(systemName: "plus")
                .foregroundColor(.black)
            }
            
            Button {

            } label: {
              Image(systemName: "gear")
                .foregroundColor(.black)
            }
          }
        }
      }//toolbar
    }
}
