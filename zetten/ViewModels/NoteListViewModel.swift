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
import GRDBCombine

class NoteListViewModel: ObservableObject {
  @Published var notes = [NoteDetailView.ViewModel]()
  @Published var searchTerm: String = ""

  @Injected var fireRepository: FirestoreNoteRepository
  @Injected var dbRepository: DatabaseRepository
  
    private var noteCancellable: AnyCancellable?
  private var cancellables = Set<AnyCancellable>()

  init() {
    // Received update from local database with new changes
//    dbRepository.notesHasChanged
//      .compactMap { return try? self.dbRepository.fetch(query: self.searchTerm) }
//      .map { notes in notes.map { note in NoteDetailView.ViewModel(note: note) } }
//      .assign(to: \.notes, on: self)
//      .store(in: &cancellables)

    // User changed search parameters
//    $searchTerm
//      .dropFirst(1)
//      .debounce(for: 0.8, scheduler: RunLoop.main)
//      .removeDuplicates()
//      .compactMap { q in
//        try? self.dbRepository.fetch(query: q)
//      }.map { notes in
//        notes.map { note in NoteDetailView.ViewModel(note: note) }
//      }
//      .assign(to: \.notes, on: self)
//      .store(in: &cancellables)

  }
    
    func onAppear() {
        $searchTerm
        .debounce(for: 0.4, scheduler: RunLoop.main)
        .removeDuplicates()
            .sink { q in
                if let cancel = self.noteCancellable {
                    cancel.cancel()
                }
                self.noteCancellable = self.notePublisher(q)
        }.store(in: &cancellables)
    }
    
    func onDisappear() {
        cancellables = Set()
    }
    
    private func notePublisher(_ q: String) -> AnyCancellable {
        try! dbRepository.fetch(query: q)
            .fetchOnSubscription()
        .map { notes in
            notes.map { note in NoteDetailView.ViewModel(note: note) }
        }
        .catch { err -> Just<[NoteDetailView.ViewModel]> in
            logger.error("Failed fetching from db: \(err)")
                return Just([])
        }
        .assign(to: \.notes, on: self)
    }

  func delete(_ indexSet: IndexSet) {
    let viewModels = indexSet.lazy.map { self.notes[$0] }
    viewModels.forEach { noteVM in
      try! fireRepository.remove(note: &noteVM.note)
    }
  }
}
