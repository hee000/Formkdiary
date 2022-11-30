//
//  HelpView.swift
//  Formkdiary
//
//  Created by hee on 2022/11/17.
//

import SwiftUI
import WebKit

struct HelpView: View {
  @Environment(\.presentationMode) var presentationMode
  
    var body: some View {
      NavigationStack{
        Webview(url: URL(string: "https://wind-felidae-57e.notion.site/42a7cac2e88b4e36a3ac4bfa75705a0f")!)
          .edgesIgnoringSafeArea(.bottom)
          .background(Color.customBg)
        
        
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarBackButtonHidden(true)
          .navigationBarTitle("도움말")
          .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
              HStack{
                Button {
                  presentationMode.wrappedValue.dismiss()
                } label: {
                  Image(systemName: "xmark")
                    .foregroundColor(Color.customIc)
                }
              }
            }
          }
      }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}


struct Webview: UIViewRepresentable {
    let url: URL
    func makeUIView(context: UIViewRepresentableContext<Webview>) -> WKWebView {
        let webview = WKWebView()
        let request = URLRequest(url: self.url, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)
        return webview
    }
    func updateUIView(_ webview: WKWebView, context: UIViewRepresentableContext<Webview>) {
        let request = URLRequest(url: self.url, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)
    }
}
