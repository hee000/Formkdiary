//
//  ExportImage.swift
//  Formkdiary
//
//  Created by hee on 2022/10/17.
//

import Foundation
import UniformTypeIdentifiers
import CoreData
import SwiftUI
import UIKit

class exportDiary {
  private var text = ""
  
  func textFileName() -> String {
    let dateComponent = Calendar.current.dateComponents([.year, .month, .day], from: Date())

    return "다이어리 내보내기(\(dateComponent.year!)년_\(dateComponent.month!)월_\(dateComponent.day!)일).text"
  }
  
  func image(page: PageMO) -> UIImage {
    let img = NavigationView {
      ZStack{
        if let monthly = page.monthly {
          MonthlyDefaultView(monthly: monthly)
        } else if let weekly = page.weekly {
          WeeklyDefaultView(weekly: weekly)
        } else if let daily = page.daily {
          DailyViewOnPage(daily: daily)
        } else if let memo = page.memo {
          MemoView(memo: memo)
        }
      }
      .navigationTitle(page.title)
      .navigationBarTitleDisplayMode(.inline)
    }.asImage()
    
    return img
  }
  
  private func pageToText(page: PageMO) {
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
  }
  
  func text(page: PageMO? = nil) -> String {
    text = "다이어리 내보내기 \n\n"
    if let page = page {
      pageToText(page: page)
    } else {
      let noteRequest: NSFetchRequest<NoteMO> = NoteMO.fetchRequest()

      guard let noteResult = try? PersistenceController.shared.context.fetch(noteRequest)
      else { return "" }
      
      for note in noteResult {
        text.append(contentsOf: "==[ 노트 : \(note.title) ]==\n\n")
        
        for page: PageMO in note.pages.toArray() {
          pageToText(page: page)
        }
        
        text.append(contentsOf: "\n\n")
      }
    }
    
    return text
  }
}
