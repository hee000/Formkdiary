//
//  PageAddDaily.swift
//  Formkdiary
//
//  Created by hee on 2022/11/02.
//

import SwiftUI

struct PageAddDaily: View {
  @EnvironmentObject var model: PageAddModel
  @ObservedObject var note: NoteMO
  
  var body: some View {
    VStack{
      Text("Daily")
        .bold()

      HStack(spacing: 0) {
        
        model.yearPicker(year: $model.selectedYear, fontsize: 14)
          .frame(width: 80,height: 200/6)
          .id(0)
        
        Spacer()
        
        model.monthPicker(month: $model.selectedMonth, fontsize: 12)
          .frame(width: 80,height: 200/6)
          .id(0)
      }
      .frame(width:2*UIScreen.main.bounds.size.width/3)

      Divider()
        .frame(width:2*UIScreen.main.bounds.size.width/3)
      
      PageAddCalView(date: model.getDate(), weekDate: $model.selectedDate, pageType: .daily)
        .frame(width:2*UIScreen.main.bounds.size.width/3)
      
      Divider()
        .frame(width:2*UIScreen.main.bounds.size.width/3)

      Spacer()

      Button{
          model.savePage(note: note)
      } label: {
        Text("만들기")
          .foregroundColor(Color.customText)
          .frame(width: UIScreen.main.bounds.size.width/4, height: UIScreen.main.bounds.size.height/20)
          .background(Color.customTextLight)
          .cornerRadius(5)
      }
    }
  }
}

