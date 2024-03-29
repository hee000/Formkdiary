//
//  KeyboardManager.swift
//  Formkdiary
//
//  Created by hee on 2022/10/27.
//

import Foundation
import SwiftUI
import Combine

class KeyboardManager: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    @Published var isVisible = false
    
    var keyboardCancellable: Cancellable?

    init() {
        keyboardCancellable = NotificationCenter.default
            .publisher(for: UIWindow.keyboardWillChangeFrameNotification)
            .sink { [weak self] notification in
                guard let self = self else { return }

                guard let userInfo = notification.userInfo else { return }
                guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

                self.isVisible = keyboardFrame.minY < UIScreen.main.bounds.height
                self.keyboardHeight = self.isVisible ? keyboardFrame.height : 0
            }
    }
}
