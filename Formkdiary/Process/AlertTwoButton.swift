//
//  AlertTwoButton.swift
//  Formkdiary
//
//  Created by hee on 2022/10/18.
//

import SwiftUI

struct AlertTwoButton<Content>: View where Content: View {
  @Binding var isPresented: Bool
  @Binding var confirm: Bool
  var content: () -> Content

  init(isPresented: Binding<Bool>, confirm: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
    self._isPresented = isPresented
    self._confirm = confirm
    self.content = content
  }
  
    var body: some View {
      ZStack{
        Color.black.opacity(0.5)
//          .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
          .edgesIgnoringSafeArea(.all)
        
          VStack(spacing: 0) {
            VStack{
              content()
            }
              .padding()
              .padding([.top, .bottom])
              .padding(.top)
            Divider()
            HStack(spacing:0){
              Button {
                self.isPresented.toggle()
              } label : {
                Text("취소")
                  .font(.system(size: 16, weight: .regular))
                  .frame(maxWidth: .infinity)
              }
              .foregroundColor(Color.customText)
              .padding()
              Divider()
              Button {
                self.confirm = true
                self.isPresented.toggle()
              } label : {
                Text("확인")
                  .font(.system(size: 16, weight: .regular))
                  .frame(maxWidth: .infinity)
              }
              .foregroundColor(Color.customText)
              .padding()
            }
            .frame(width:UIScreen.main.bounds.width * 2/3)
            .fixedSize()
          }
          .frame(width: UIScreen.main.bounds.width * 2/3)
          .background(Color.customBg)
          .cornerRadius(5)
          .transition(AnyTransition.opacity.animation(Animation.easeInOut))
      }
    }
}
