//
//  PageAddWeeklyView.swift
//  Formkdiary
//
//  Created by hee on 2022/11/02.
//

import SwiftUI

struct PageAddWeekly: View {
  @EnvironmentObject var model: PageAddModel
  @ObservedObject var note: NoteMO
  
  var body: some View {
    VStack{
      Text("Weekly")
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
      
      PageAddCalView(date: model.getDate(), weekDate: $model.selectedWeekDate)
        .frame(width:2*UIScreen.main.bounds.size.width/3)
      
      Divider()
        .frame(width:2*UIScreen.main.bounds.size.width/3)
      
      Text("스타일 설정")
        .bold()
        .frame(width:2*UIScreen.main.bounds.size.width/3, alignment: .center)
        .padding([.top, .bottom])
        .padding(.top)
      
      HStack{
        Button{
          model.weekStyle = Int32(1)
        } label: {
          VStack{
            VStack{
              HStack{
                Rectangle()
                  .fill(Color.gray)
                  .cornerRadius(5)
                Rectangle()
                  .fill(Color.gray)
                  .cornerRadius(5)
              }
              HStack{
                Rectangle()
                  .fill(Color.gray)
                  .cornerRadius(5)
                Rectangle()
                  .fill(Color.clear)
                  .cornerRadius(5)
              }
            }
            .padding([.leading, .trailing])
            .padding([.leading, .trailing])
            Text("두줄보기")
          }
        }
        .frame(height: 60)
        
        Button{
          model.weekStyle = Int32(0)
        } label: {
          VStack{
            VStack{
              Rectangle()
                .fill(Color.gray)
                .cornerRadius(5)
              Rectangle()
                .fill(Color.gray)
                .cornerRadius(5)
              Rectangle()
                .fill(Color.gray)
                .cornerRadius(5)
            }
            .padding([.leading, .trailing])
            .padding([.leading, .trailing])
            Text("한줄보기")
          }
        }
      }
      .frame(height: 60)
      .frame(width:2*UIScreen.main.bounds.size.width/3)
      
      Spacer()
      
      Button {
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
