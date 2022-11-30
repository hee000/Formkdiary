//
//  SettingView.swift
//  Formkdiary
//
//  Created by hee on 2022/10/27.
//

import SwiftUI

struct SettingView: View {
  @Environment(\.presentationMode) var presentationMode

  @AppStorage("StartMonday") var startMonday: Bool = UserDefaults.standard.bool(forKey: "StartMonday")
  
  @AppStorage("EnglishDay") var englishDay: Bool = UserDefaults.standard.bool(forKey: "EnglishDay")
  
  @AppStorage("DarkMode") var darkMode: Bool = UserDefaults.standard.bool(forKey: "DarkMode")
  
//  @AppStorage("AppLock") var appLock: Bool = UserDefaults.standard.bool(forKey: "AppLock")
  
  @Environment(\.colorScheme) private var colorScheme
  
  @State var isStartDay = false
  
  @State var isEnglishDay = false
  
  var body: some View {
    NavigationView{
      ScrollView {
        VStack{
          HStack{
            Text("테마")
              .frame(maxWidth: .infinity, alignment: .leading)
              .font(.system(size: 15, weight: .regular))
              .foregroundColor(Color.customText)
            
            Picker("테마", selection: $darkMode) {
              ForEach([true, false], id:\.self) { bool in
                Text(bool ? "다크" : "라이트").tag(bool)
              }
            }
            .pickerStyle(SegmentedPickerStyle())
          }
          
          Divider()
            .padding(.vertical)
          
//          VStack {
//            Text("글자옵션")
//              .frame(maxWidth: .infinity, alignment: .leading)
//            Text("글자크기")
//              .frame(maxWidth: .infinity, alignment: .leading)
//            Text("줄 간격")
//              .frame(maxWidth: .infinity, alignment: .leading)
//          }
//
//          Divider()
//            .padding(.vertical)
          
          VStack {
            Text("캘린더 설정")
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.bottom)
              .foregroundColor(Color.customText)
              .font(.system(size: 12, weight: .regular))
            
            Button{
              isStartDay.toggle()
            } label: {
              Text("한 주의 시작")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.customText)
                .font(.system(size: 15, weight: .regular))
            }
            .padding(.bottom)
            .confirmationDialog("현재 시작 요일: \(!startMonday ? "일요일" : "월요일")", isPresented: $isStartDay, titleVisibility: .visible) {
              Button("일요일", role: .destructive) {
                startMonday = false
                CalendarModel.shared.refeshCalFistWeekday()
              }
              
              Button("월요일") {
                startMonday = true
                CalendarModel.shared.refeshCalFistWeekday()
              }

              Button("취소", role: .cancel) { }
            }

            
            Button{
              isEnglishDay.toggle()
            } label: {
              Text("요일 표기")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.customText)
                .font(.system(size: 15, weight: .regular))
            }
            .confirmationDialog("현재 요일 표기: \(!englishDay ? "국문" : "영문")", isPresented: $isEnglishDay, titleVisibility: .visible) {
              Button("월 화 수") {
                englishDay = false
                startWeekRefresh()
              }
              
              Button("Mon Tue Wed") {
                englishDay = true
                startWeekRefresh()
              }

              Button("취소", role: .cancel) { }
            }
          }
          
          Divider()
            .padding(.vertical)
          
//          VStack {
//            Text("보안")
//              .frame(maxWidth: .infinity, alignment: .leading)
//
//            Toggle("앱 잠금", isOn: $appLock)
//          }
          
        }//v
        .padding()
        .padding()
      }//scroll
      .background(Color.customBg)
      .preferredColorScheme(darkMode ? .dark : .light)
      .navigationTitle("설정")
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarBackButtonHidden(true)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            presentationMode.wrappedValue.dismiss()
          } label: {
            Image(systemName: "xmark")
              .foregroundColor(Color.customText)
          }
        }
      }//toolbar
    }//navi
  }
}
