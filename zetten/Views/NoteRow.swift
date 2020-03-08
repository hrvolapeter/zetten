//
//  NoteRow.swift
//  zetten
//
//  Created by Peter Hrvola on 08/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import SwiftUI

struct NoteRow: View {
  @ObservedObject var vm: NoteDetailView.ViewModel

  var body: some View {
    VStack(alignment: .leading) {
      Text(vm.note.title).padding(.init(top: 0, leading: 0, bottom: 5, trailing: 0))
      HStack {
        ForEach(vm.note.tags, id: \.self) { tag in
          Text(tag)
            .font(.footnote)
            .padding(3)
            .background(Color.accentColor)
            .cornerRadius(4)
            .foregroundColor(.white)
        }.lineLimit(1)
        Spacer()
        Text(vm.note.createdTime.getFormattedDate()).font(.caption).foregroundColor(.gray)
          .lineLimit(1)
      }
    }
  }
}

struct NoteRow_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      NoteRow(vm: .init(note: notePreview))
    }.previewLayout(.sizeThatFits)
  }
}
