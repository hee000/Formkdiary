//
//  TextView.swift
//  Formkdiary
//
//  Created by hee on 2022/10/27.
//

import SwiftUI

struct TextView: UIViewRepresentable {
 
  @Binding var text: String
  @Binding var textStyle: UIFont.TextStyle
 
  func makeCoordinator() -> Coordinator {
      Coordinator($text)
  }
   
  class Coordinator: NSObject, UITextViewDelegate {
      var text: Binding<String>
   
      init(_ text: Binding<String>) {
          self.text = text
      }
   
      func textViewDidChange(_ textView: UITextView) {
          self.text.wrappedValue = textView.text
      }
  }
  
    func makeUIView(context: Context) -> UITextView {
      let textView = UITextView()

      textView.text = text
    
      textView.font = UIFont.preferredFont(forTextStyle: textStyle)
      textView.autocapitalizationType = .none
      textView.isSelectable = true
      textView.isUserInteractionEnabled = true
      textView.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15);
      textView.delegate = context.coordinator
      return textView
    }
 
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.font = UIFont.preferredFont(forTextStyle: textStyle)
    }
}
