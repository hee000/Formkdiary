//
//  TextFile.swift
//  Formkdiary
//
//  Created by cch on 2022/09/24.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI
import CoreData

struct TextFile: FileDocument {
    // tell the system we support only plain text
    static var readableContentTypes = [UTType.plainText]

    // by default our document is empty
    var text = ""

    // a simple initializer that creates new, empty documents
    init() {
        text = "다이어리 내보내기 \n"
      

      text.append(contentsOf: "\n")
//      print(text)
      
      let noteRequest: NSFetchRequest<NoteMO> = NoteMO.fetchRequest()

      guard let noteResult = try? PersistenceController.shared.container.viewContext.fetch(noteRequest)
      else { return }

      for note in noteResult {
        text.append(contentsOf: "==[ 노트 : \(note.title) ]==\n\n")
        
        for page: PageMO in note.pages.toArray() {
          if let monthly = page.monthly {
            let dailies: [DailyMO] = monthly.dailies.toArray()
            text.append(contentsOf: "[ 페이지: \(page.title) (먼슬리) ]\n")
            
            for daily in dailies {
              if daily.text != "" {
                text.append(contentsOf: "\(daily.date.toString(dateFormat: "yyyy-MM-dd"))\n\(daily.text)\n")
              }
            }
            text.append(contentsOf: "\n")
            
          } else if let weekly = page.weekly {
            let dailies: [DailyMO] = weekly.dailies.toArray()
            text.append(contentsOf: "[ 페이지: \(page.title) (위클리) ]\n")
            
            for daily in dailies {
              if daily.text != "" {
                text.append(contentsOf: "\(daily.date.toString(dateFormat: "yyyy-MM-dd"))\n\(daily.text)\n")
              }
            }
            text.append(contentsOf: "\n")
            
          } else if let daily = page.daily {
            text.append(contentsOf: "[ 페이지: \(page.title) (데일리) ]\n")
            
            if daily.text != "" {
              text.append(contentsOf: "\(daily.text)\n")
            }
            text.append(contentsOf: "\n")

          } else if let memo = page.memo {
            text.append(contentsOf: "[ 페이지: \(page.title) (메모) ]\n")
            
            if memo.text != "" {
              text.append(contentsOf: "\(memo.text)\n")
            }
            text.append(contentsOf: "\n")
          }
        } //page
        
        text.append(contentsOf: "\n\n")
      } //note

      print(text)
    }

    // this initializer loads data that has been saved previously
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }

    // this will be called when the system wants to write our data to disk
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        let dateComponent = Calendar.current.dateComponents([.year, .month, .day], from: Date())
      
        fileWrapper.filename = "다이어리 내보내기(\(dateComponent.year!)년_\(dateComponent.month!)월_\(dateComponent.day!)일)"
      
        return fileWrapper
    }
}
