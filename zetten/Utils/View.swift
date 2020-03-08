import SwiftUI

/// Copy right Benjamin Mayo
extension View {
  @ViewBuilder func `if`<T>(_ condition: Bool, transform: (Self) -> T) -> some View where T: View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}
