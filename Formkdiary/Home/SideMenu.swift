//
//  SideMenu.swift
//  Formkdiary
//
//  Created by hee on 2022/11/16.
//

import SwiftUI

struct SideMenu: View {
  let width: CGFloat
  let isOpen: Bool
  let menuClose: () -> Void
  let diaryExport: () -> Void
  let openSetting: () -> Void
  let openSearch: () -> Void
  @State private var offset = CGSize.zero


  var body: some View {
    ZStack {
      GeometryReader { _ in
          EmptyView()
      }
      .background(Color.black.opacity(0.3).ignoresSafeArea())
//      .opacity(self.isOpen ? 1.0 : 0.0)
      .opacity(self.isOpen ? ((width + offset.width) / width) : 0.0)
      .onChange(of: isOpen, perform: { newValue in
        if newValue {
          withAnimation{
            offset = .zero
          }
        }
      })
      .onTapGesture {
        self.menuClose()
      }
      
      HStack {
        MenuContent(diaryExport: diaryExport, openSetting: openSetting, openSearch: openSearch)
          .frame(width: self.width)
          .background(Color.customBg)
          .offset(x: self.isOpen ? 0 + offset.width : -self.width)

        Spacer()
      }
      
    } //z
    .gesture(
      DragGesture()
        .onChanged { gesture in
          if gesture.translation.width < 0 {
            withAnimation(.linear(duration: 0)) {
              offset = gesture.translation
            }
          } else {
            if offset.width < 0 {
              withAnimation(.linear(duration: 0)) {
                offset.width = 0
              }
            }
          }
        }
        .onEnded { _ in
          if offset.width < -self.width/2 {
            self.menuClose()
          } else {
            withAnimation {
              offset = .zero
            }
          }
        }
    ) //gesture
  }
}


struct MenuContent: View {
  let diaryExport: () -> Void
  let openSetting: () -> Void
  let openSearch: () -> Void
  
  @AppStorage("StartMonday") var startMonday: Bool = UserDefaults.standard.bool(forKey: "StartMonday")
  @State var isDaySetting = false
  @State var isHelp = false
  
    var body: some View {
      VStack{
        List{
          Color.clear
            .listRowSeparator(.hidden)
            .listRowBackground(Color.customBg)
          
          Color.clear
            .listRowSeparator(.hidden)
            .listRowBackground(Color.customBg)
          
          Button{
            openSearch()
          } label: {
            Label("검색", systemImage: "magnifyingglass")
              .foregroundColor(Color.customText)
          }
          .listRowSeparator(.hidden)
          .listRowBackground(Color.customBg)
          
          Button{
            openSetting()
          } label: {
            Label("설정", systemImage: "gearshape")
              .foregroundColor(Color.customText)
          }
          .listRowSeparator(.hidden)
          .listRowBackground(Color.customBg)
          
          Button{
            diaryExport()
          } label: {
            Label("내보내기", systemImage: "square.and.arrow.up")
              .foregroundColor(Color.customText)
          }
          .listRowSeparator(.hidden)
          .listRowBackground(Color.customBg)
          
          Button{
            isHelp.toggle()
          } label: {
            Label("도움말", systemImage: "questionmark.circle")
              .foregroundColor(Color.customText)
          }
          .listRowSeparator(.hidden)
          .listRowBackground(Color.customBg)
          
        }
        .scrollContentBackground(.hidden)
        .background(Color.customBg)
        
        Text("\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
          .font(.footnote)
          .foregroundColor(.gray)
          .bold()
        Text("inquiry: sy589610@gmail.com")
          .font(.footnote)
          .foregroundColor(.gray)
          .tint(.gray)
          .bold()
      }
      .fullScreenCover(isPresented: $isHelp) {
        HelpView()
      }

    }
}
