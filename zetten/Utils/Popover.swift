import SwiftUI

/// Workaround for actionSheet not present on Mac os even when officially supported
/// Display pop sheet on macos and ipad instead
/// From https://stackoverflow.com/questions/56910941/present-actionsheet-in-swiftui-on-ipad/58490096#58490096
/// Copyright marcprux
extension View {
  /// Creates an `ActionSheet` on an iPhone or the equivalent `popover` on an iPad, in order to work around `.actionSheet` crashing on iPad (`FB7397761`).
  ///
  /// - Parameters:
  ///     - isPresented: A `Binding` to whether the action sheet should be shown.
  ///     - content: A closure returning the `PopSheet` to present.
  public func popSheet(isPresented: Binding<Bool>, content: @escaping () -> PopSheet) -> some View {
    Group {
      if UIDevice.current.userInterfaceIdiom != .phone {
        popover(isPresented: isPresented, content: { content().popover(isPresented: isPresented) })
      } else {
        actionSheet(isPresented: isPresented, content: { content().actionSheet() })
      }
    }
  }
}

/// A `Popover` on iPad and an `ActionSheet` on iPhone.
public struct PopSheet {
  let title: Text
  let message: Text?
  let buttons: [PopSheet.Button]

  /// Creates an action sheet with the provided buttons.
  public init(title: Text, message: Text? = nil, buttons: [PopSheet.Button] = [.cancel()]) {
    self.title = title
    self.message = message
    self.buttons = buttons
  }

  /// Creates an `ActionSheet` for use on an iPhone device
  func actionSheet() -> ActionSheet {
    ActionSheet(
      title: title, message: message,
      buttons: buttons.map({ popButton in
        // convert from PopSheet.Button to ActionSheet.Button (i.e., Alert.Button)
        switch popButton.kind {
        case .default: return .default(popButton.label, action: popButton.action)
        case .cancel: return .cancel(popButton.label, action: popButton.action)
        case .destructive: return .destructive(popButton.label, action: popButton.action)
        }
      }))
  }

  /// Creates a `.popover` for use on an iPad device
  func popover(isPresented: Binding<Bool>) -> some View {
    VStack {
      self.title.padding(.top)
      Divider()
      List {
        ForEach(Array(self.buttons.enumerated()), id: \.offset) { (offset, button) in
          VStack {
            if button.kind == .cancel {
              SwiftUI.Button(
                action: {
                  // hide the popover whenever an action is performed
                  isPresented.wrappedValue = false
                  // another bug: if the action shows a sheet or popover, it will fail unless this one has already been dismissed
                  DispatchQueue.main.async {
                    button.action?()
                  }
                },
                label: {
                  button.label.foregroundColor(.red).fontWeight(.bold)
                })
            } else {
              SwiftUI.Button(
                action: {
                  // hide the popover whenever an action is performed
                  isPresented.wrappedValue = false
                  // another bug: if the action shows a sheet or popover, it will fail unless this one has already been dismissed
                  DispatchQueue.main.async {
                    button.action?()
                  }
                },
                label: {
                  button.label.font(.subheadline)
                })
            }
          }
        }
      }
    }
  }

  /// A button representing an operation of an action sheet or popover presentation.
  ///
  /// Basically duplicates `ActionSheet.Button` (i.e., `Alert.Button`).
  public struct Button {
    let kind: Kind
    let label: Text
    let action: (() -> Void)?
    enum Kind { case `default`, cancel, destructive }

    /// Creates a `Button` with the default style.
    public static func `default`(_ label: Text, action: (() -> Void)? = {}) -> Self {
      Self(kind: .default, label: label, action: action)
    }

    /// Creates a `Button` that indicates cancellation of some operation.
    public static func cancel(_ label: Text, action: (() -> Void)? = {}) -> Self {
      Self(kind: .cancel, label: label, action: action)
    }

    /// Creates an `Alert.Button` that indicates cancellation of some operation.
    public static func cancel(_ action: (() -> Void)? = {}) -> Self {
      Self(kind: .cancel, label: Text("Cancel"), action: action)
    }

    /// Creates an `Alert.Button` with a style indicating destruction of some data.
    public static func destructive(_ label: Text, action: (() -> Void)? = {}) -> Self {
      Self(kind: .destructive, label: label, action: action)
    }
  }
}
