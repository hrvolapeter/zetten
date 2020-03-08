//
//  NoteList.swift
//  zetten
//
//  Created by Peter Hrvola on 08/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import Resolver
import SwiftUI

/// View showing searchable list of notes
struct NoteListView: View {
  @ObservedObject var vm = NoteListViewModel()
  @State private var editingList = false
  @State private var showingEditMenu = false
  @State var activeChildView = false
  @State var childNote = NoteDetailView(vm: .newNote())

  var body: some View {
    NavigationView {
      VStack(alignment: .leading) {
        SearchBar(text: $vm.searchTerm)
        list
        newNote
        childNoteView
      }
      if vm.notes.count > 0 {
        MultiColumnListPlaceholderView()
      }
    }
  }

  var childNoteView: some View {
    NavigationLink(destination: childNote, isActive: $activeChildView) { EmptyView() }.disabled(
      true)
  }

  var list: some View {
    List {
      ForEach(vm.notes, id: \.note.id) { note in
        VStack {
          NavigationLink(destination: NoteDetailView(vm: note)) {
            NoteRow(vm: note).contextMenu {
              Button(
                action: {
                  logger.debug("Context menu: create child pressed")
                  self.childNote = NoteDetailView(vm: .newNote(parentId: note.note.id))
                  self.activeChildView.toggle()
                }, label: { Text("Create child") })
            }
          }.isDetailLink(true)
        }
      }.onDelete(perform: vm.delete)
    }.navigationBarTitle("Notes")
      .navigationBarItems(trailing: barItems)
      .environment(\.editMode, .constant(self.editingList ? EditMode.active : EditMode.inactive))
  }

  var newNote: some View {
    NavigationLink(destination: NoteDetailView(vm: .newNote())) {
      HStack {
        Image(systemName: "plus.circle.fill")
          .resizable()
          .frame(width: 20, height: 20)
        Text("New Note")
      }
    }.padding()
      .accentColor(Color(.systemBlue))
  }

  var barItems: some View {
    HStack {
      NavigationLink(destination: UserView()) {
        Image(systemName: "person.circle")
          .resizable()
          .frame(width: 25, height: 25)
      }
      Button(action: {
        self.showingEditMenu.toggle()
      }) {
        Image(systemName: "ellipsis.circle")
          .resizable()
          .frame(width: 25, height: 25)
      }.popSheet(isPresented: $showingEditMenu) {
        PopSheet(
          title: Text(""),
          buttons: [
            .default(Text("Select notes"), action: { self.editingList.toggle() }), .cancel(),
          ])
      }
    }
  }
}

struct NoteList_Previews: PreviewProvider {
  static var previews: some View {
    ForEach(["iPad Pro (11-inch)", "iPhone Xs"], id: \.self) { deviceName in
      NoteListView()
        .previewDevice(PreviewDevice(rawValue: deviceName))
        .previewDisplayName(deviceName)

    }
  }
}
