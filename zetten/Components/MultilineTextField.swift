//
//  MultilineTextField.swift
//  zetten
//
//  Created by Peter Hrvola on 27/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import SwiftUI

/// SwiftUI doesn't support multiline text fields, this is workaround using UIKiit
/// From: https://stackoverflow.com/questions/56471973/how-do-i-create-a-multiline-textfield-in-swiftui
/// Copyrights Asperi
fileprivate struct UITextViewWrapper: UIViewRepresentable {
    typealias UIViewType = UITextView
    
    @Binding var text: String
    @Binding var calculatedHeight: CGFloat
    var onDone: (() -> Void)?
    
    func makeUIView(context: Context) -> UITextView {
        let textField = UITextView()
        textField.delegate = context.coordinator
        
        textField.isEditable = true
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.isSelectable = true
        textField.isUserInteractionEnabled = true
        textField.isScrollEnabled = false
        textField.textContainer.lineFragmentPadding = 0
        textField.textContainerInset = .zero
        textField.backgroundColor = UIColor.clear
        if nil != onDone {
            textField.returnKeyType = .done
        }
        
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textField
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != self.text {
            uiView.text = self.text
            UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight)
        }
    }
    
    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(
            CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                result.wrappedValue = newSize.height  // !! must be called asynchronously
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, height: $calculatedHeight, onDone: onDone)
    }
    
    final class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        var calculatedHeight: Binding<CGFloat>
        var onDone: (() -> Void)?
        
        init(text: Binding<String>, height: Binding<CGFloat>, onDone: (() -> Void)? = nil) {
            self.text = text
            self.calculatedHeight = height
            self.onDone = onDone
        }
        
        func textViewDidChange(_ uiView: UITextView) {
            text.wrappedValue = uiView.text
            UITextViewWrapper.recalculateHeight(view: uiView, result: calculatedHeight)
        }
        
        func textView(
            _ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String
        ) -> Bool {
            if let onDone = self.onDone, text == "\n" {
                textView.resignFirstResponder()
                onDone()
                return false
            }
            return true
        }
    }
    
}

struct MultilineTextField: View {
    private var onCommit: (() -> Void)?
    @Binding private var text: String
    @State private var dynamicHeight: CGFloat = UIScreen.main.bounds.height
    private var minHeight: CGFloat = UIScreen.main.bounds.height
    private var internalText: Binding<String> {
      Binding<String>(get: { self.text }) {
        self.text = $0
      }
    }
    
    init(text: Binding<String>, onCommit: (() -> Void)? = nil) {
        self.onCommit = onCommit
        self._text = text
    }
    
    var body: some View {
        UITextViewWrapper(text: internalText, calculatedHeight: $dynamicHeight, onDone: onCommit)
            .frame(minHeight: max(dynamicHeight, minHeight), maxHeight: max(dynamicHeight, minHeight))
    }
}

/// Workaround for focus ring displaying on MacOS
/// From https://stackoverflow.com/questions/57577345/blue-highlighting-focus-ring-on-catalyst-app
/// Copyright Amerino
extension UITextView {
    #if targetEnvironment(macCatalyst)
    @objc(_focusRingType)
    var focusRingType: UInt {
        return 1  //NSFocusRingTypeNone
    }
    #endif
}

// MARK: TypeaheadTextField

