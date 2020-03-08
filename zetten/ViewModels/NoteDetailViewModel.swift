//
//  NoteDetailViewModel.swift
//  zetten
//
//  Created by Peter Hrvola on 13/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import Combine
import Foundation
import Resolver

extension NoteDetailView {
  class ViewModel: ObservableObject {
    @Injected var fireRepository: FirestoreNoteRepository
    @Published var note: Note
    @Published var tagsField = ""
    private var noteHasChanged = false

    private var cancellables = Set<AnyCancellable>()

    init(note: Note) {
      self.note = note
    }

    func onAppear() {
      noteHasChanged = false

      // Save note after 10s when it has changed
      self.$note
        .dropFirst()
        .debounce(for: 10, scheduler: RunLoop.main)
        .removeDuplicates().sink { note in
          logger.debug("Note has changed saving after 10s \(note.id)")
          return self.save()
        }.store(in: &cancellables)

      self.$note.dropFirst().sink { _ in
        self.noteHasChanged = true
      }.store(in: &cancellables)
    }

    func onDisapper() {
      cancellables = Set()
      if noteHasChanged {
        save()
      }
    }

    func save() {
      logger.debug("Saving note: \(note.id)")
      try! self.fireRepository.save(note: &self.note)
    }

    func removeTag(_ tag: String) {
      self.note.tags = self.note.tags.filter({ x in tag != x })
    }

    func addTag() {
      self.note.tags.append(tagsField)
      self.tagsField = ""
    }

    static func newNote() -> NoteDetailView.ViewModel {
      self.newNote(parentId: nil)
    }

    static func newNote(parentId: String?) -> NoteDetailView.ViewModel {
      NoteDetailView.ViewModel(note: .init(title: "", content: "", parentId: parentId, tags: []))
    }
  }
}
