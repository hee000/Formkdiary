//
//  PageAddMonthly.swift
//  Formkdiary
//
//  Created by hee on 2022/11/02.
//

import SwiftUI

struct PageAddMonthly: View {
  @EnvironmentObject var model: PageAddModel
  @ObservedObject var note: NoteMO

  var body: some View {
    VStack{
      Text("Monthly")
        .bold()
      
      HStack(spacing:0){
        model.yearPicker(year: $model.selectedYear, fontsize: 20)
        model.monthPicker(month: $model.selectedMonth, fontsize: 20)
      }
      .frame(height: 100)
      
      Spacer()

      Button{
        model.savePage(note: note)
      } label: {
        Text("추가하기")
          .foregroundColor(Color.customText)
          .frame(width: UIScreen.main.bounds.size.width/4, height: UIScreen.main.bounds.size.height/20)
          .background(Color.customTextLight)
          .cornerRadius(5)
      }
    }
  }
}
