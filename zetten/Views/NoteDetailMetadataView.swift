//
//  NoteDetailMetadata.swift
//  zetten
//
//  Created by Peter Hrvola on 15/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import FirebaseFirestore
import SwiftUI

/// View showing metadata about note
/// In the future should include tree of parents and tags also possiblity to change parent
struct NoteDetailMetadataView: View {
  @ObservedObject var vm: NoteDetailView.ViewModel

  var body: some View {
    VStack(alignment: .center) {
      Text(vm.note.title)
      Text("Created: \(vm.note.createdTime.getFormattedDate())")
      // TODO: Show tree of parents
      Button(action: {}) { Text("Parent: \(vm.note.parentId ?? "")") }
      Spacer()
    }
  }
}

struct NoteDetailMetadata_Previews: PreviewProvider {
  static var previews: some View {
    return NoteDetailMetadataView(vm: .init(note: notePreview))
  }
}
