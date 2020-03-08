//
//  NoteDetail.swift
//  zetten
//
//  Created by Peter Hrvola on 08/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import SwiftUI
import UIKit

/// View generating note detail
struct NoteDetailView: View {
  @ObservedObject var vm: ViewModel
  @State var showingActionSheet = false
  @State var isShowingMetadataView = false
  @State var isShowingTreeView = false

  var body: some View {
    ScrollView {
      VStack {
        TextField("Title", text: $vm.note.title)
          .font(.title)
        TextField("Tags", text: $vm.tagsField, onCommit: vm.addTag)
          .font(.callout)
        tags
        MultilineTextField(text: $vm.note.content)

        NavigationLink(
          destination: NoteDetailMetadataView(vm: self.vm),
          isActive: $isShowingMetadataView,
          label: { EmptyView() }
        )
        NavigationLink(
          destination: TreeView(vm: .init(note: self.vm.note)),
          isActive: $isShowingTreeView,
          label: { EmptyView() }
        )
      }.padding()

    }.navigationBarTitle("", displayMode: .inline)
      .navigationBarItems(trailing: barItems)
      .onDisappear {
        logger.debug("Dissapearing\(self.vm.note.id): \(self.vm.note.title)")
        self.vm.onDisapper()
      }.onAppear(perform: self.vm.onAppear)
  }

  var tags: some View {
    ScrollView(.horizontal) {
      HStack {
        ForEach(vm.note.tags, id: \.self) { tag in
          HStack {
            Text(tag).font(.footnote)
            Button(action: { self.vm.removeTag(tag) }) {
              Image(systemName: "xmark.circle.fill")
            }
          }.padding(7).lineLimit(1).background(Color.accentColor).foregroundColor(.white)
            .cornerRadius(10)

        }
      }
    }
  }

  // Actionsheet menu for metadata
  var barItems: some View {
    Button(action: {
      self.showingActionSheet.toggle()
    }) {
      Image(systemName: "ellipsis.circle")
        .resizable()
        .frame(width: 25, height: 25)
    }.popSheet(isPresented: $showingActionSheet) {
      PopSheet(
        title: Text(""),
        buttons: [
          .default(
            Text("Info"),
            action: { self.isShowingMetadataView.toggle() }
          ),
          .default(
            Text("Tree"),
            action: { self.isShowingTreeView.toggle() }
          ),
          .cancel(),
        ]
      )
    }
  }

}

struct NoteDetail_Previews: PreviewProvider {
  static var previews: some View {
    NoteDetailView(vm: .init(note: notePreview))
  }
}

// MARK: MultilineTextField

/// SwiftUI doesn't support multiline text fields, this is workaround using UIKiit
/// From: https://stackoverflow.com/questions/56471973/how-do-i-create-a-multiline-textfield-in-swiftui
/// Copyrights Asperi
fileprivate struct UITextViewWrapper: UIViewRepresentable {
  typealias UIViewType = UITextView

  @Binding var text: String
  @Binding var calculatedHeight: CGFloat
  var onDone: (() -> Void)?

  func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>) -> UITextView {
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

  func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<UITextViewWrapper>) {
    if uiView.text != self.text {
      uiView.text = self.text
    }
    // TODO: is stealing focus when editing title
    //                if uiView.window != nil, !uiView.isFirstResponder {
    //                    uiView.becomeFirstResponder()
    //                }
    UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight)
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

  private var internalText: Binding<String> {
    Binding<String>(get: { self.text }) {
      self.text = $0
    }
  }

  @State private var dynamicHeight: CGFloat = UIScreen.main.bounds.height

  // Used to cover whole screen even when empty
  // TODO: this actually overlays behind the screen
  private var minHeight: CGFloat = UIScreen.main.bounds.height

  init(text: Binding<String>, onCommit: (() -> Void)? = nil) {
    self.onCommit = onCommit
    self._text = text
  }

  var body: some View {
    UITextViewWrapper(text: self.internalText, calculatedHeight: $dynamicHeight, onDone: onCommit)
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
