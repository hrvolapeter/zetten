//
//  TypeaheadTextfield.swift
//  zetten
//
//  Created by Peter Hrvola on 27/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import SwiftUI

struct TypeaheadTextField: View {
    @Binding private var text: String
    @Binding private var typeahead: String
    private var placeholder: String?
    private var onCommit: (() -> Void)?
    
    init(_ placeholder: String?, text: Binding<String>, typeahead: Binding<String>, onCommit: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self._text = text
        self._typeahead = typeahead
        self.onCommit = onCommit
    }
    
    var body: some View {
        TypeaheadTextViewWrapper(text: $text, typeahead: $typeahead, onCommit: onCommit).background(placeholderView, alignment: .leading)
    }
    
    var placeholderView: some View {
        Group {
            if (placeholder != nil && text.count == 0) {
                Text(placeholder!).foregroundColor(.gray)
            }
        }
    }
}

fileprivate struct TypeaheadTextViewWrapper: UIViewRepresentable {
    typealias UIViewType = UITextView
    @Binding var text: String
    @Binding var typeahead: String
    var onCommit: (() -> Void)?
    
    
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
        textField.returnKeyType = .done
        textField.deleteBackward()
        return textField
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        let res = typeahead.count != 0 && text.count > 0 ? typeahead : text
        print(text)
        if uiView.text != res {
            uiView.text = res
            let textPosition = uiView.position(from: uiView.beginningOfDocument, offset: text.count)!
            uiView.selectedTextRange = uiView.textRange(from: textPosition, to: uiView.endOfDocument)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, onCommit: onCommit)
    }
    
    final class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        var onCommit: (() -> Void)?

        
        init(text: Binding<String>, onCommit: (() -> Void)?) {
            self.text = text
            self.onCommit = onCommit
        }
        
        func textViewDidChange(_ uiView: UITextView) {
            text.wrappedValue = uiView.text
        }
        
        func textView(
            _ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String
        ) -> Bool {
            if let onCommit = self.onCommit, text == "\n" {
                textView.resignFirstResponder()
                onCommit()
                return false
            }
            return true
        }
    }
    
}
