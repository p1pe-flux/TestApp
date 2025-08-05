//
//  View+KeyboardAdaptive.swift
//  WorkoutTracker
//
//  Modificador para manejar el teclado de manera más eficiente
//

import SwiftUI
import Combine

extension View {
    func keyboardAdaptive() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive())
    }
}

struct KeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .frame(width: geometry.size.width, height: geometry.size.height)
                .onReceive(Publishers.keyboardHeight) { height in
                    withAnimation(.easeOut(duration: 0.25)) {
                        self.keyboardHeight = height
                    }
                }
                .padding(.bottom, keyboardHeight)
        }
    }
}

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
            }
        
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ -> CGFloat in 0 }
        
        return MergeMany([willShow, willHide])
            .eraseToAnyPublisher()
    }
}

// Modificador adicional para dismissar el teclado
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            hideKeyboard()
        }
    }
}
