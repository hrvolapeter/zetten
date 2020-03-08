//
//  NoteListViewModel.swift
//  zetten
//
//  Created by Peter Hrvola on 13/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import Combine
import FirebaseFirestore
import Foundation
import Resolver

class NoteListViewModel: ObservableObject {
  @Published var notes = [NoteDetailView.ViewModel]()
  @Published var searchTerm: String = ""

  @Injected var fireRepository: FirestoreNoteRepository
  @Injected var dbRepository: DatabaseRepository

  private var cancellables = Set<AnyCancellable>()

  init() {
    // Received update from local database with new changes
    dbRepository.notesHasChanged
      .compactMap { return try? self.dbRepository.fetch(query: self.searchTerm) }
      .map { notes in notes.map { note in NoteDetailView.ViewModel(note: note) } }
      .assign(to: \.notes, on: self)
      .store(in: &cancellables)

    // User changed search parameters
    $searchTerm
      .dropFirst(1)
      .debounce(for: 0.8, scheduler: RunLoop.main)
      .removeDuplicates()
      .compactMap { q in
        try? self.dbRepository.fetch(query: q)
      }.map { notes in
        notes.map { note in NoteDetailView.ViewModel(note: note) }
      }
      .assign(to: \.notes, on: self)
      .store(in: &cancellables)

  }

  func delete(_ indexSet: IndexSet) {
    let viewModels = indexSet.lazy.map { self.notes[$0] }
    viewModels.forEach { noteVM in
      try! fireRepository.remove(note: &noteVM.note)
    }
  }
}
