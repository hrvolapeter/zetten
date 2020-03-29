//
//  TreeViewModel.swift
//  zetten
//
//  Created by Peter Hrvola on 18/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import Combine
import Foundation
import Resolver
import SwiftUI

extension TreeView {
  class ViewModel: ObservableObject {
    @Published var note: Note
    @Published var tree: [[Note]] = []
    @Published var searchTerm: String = ""
    @Published var searchResult: [Note] = []

    @Injected private var dbRepository: DatabaseRepository
    @Injected private var fireRepository: FirestoreNoteRepository

    private var cancellables = Set<AnyCancellable>()

    init(note: Note) {
      self.note = note
    }

    func onAppear() {
      buildTree()

        try! dbRepository.fetch(query: "").assertNoFailure().sink { _ in
            self.buildTree()
        }.store(in: &cancellables)

      $searchTerm
        .dropFirst(1)
        .debounce(for: 0.8, scheduler: RunLoop.main)
        .removeDuplicates()
        .compactMap { q in
          try? self.dbRepository.fetchAll(query: q)
        }
        .assign(to: \.searchResult, on: self)
        .store(in: &cancellables)
    }

    func onDisappear() {
      cancellables.forEach { cancellable in cancellable.cancel() }
    }

    func changeParent(parent: Note, childId: String) {
      guard
        var child = try! dbRepository.fetch(id: childId)
      else { return }
      child.parentId = parent.id
      try! fireRepository.save(note: &child)
    }

    private func buildTree() {
      let root = try! getRoot()
      var tree: [[Note]] = [[root]]
      var i = 0
      repeat {
        tree.append([])
        for note in tree[i] {
          let children = try! dbRepository.fetch_children(note: note)
          tree[i + 1].append(contentsOf: children)
        }
        i += 1
      } while tree[i].count != 0
      self.tree = tree
    }

    private func getRoot() throws -> Note {
      var parent = try dbRepository.fetch_parent(note: note)
      var previous = parent
      while parent != nil {
        previous = parent
        parent = try dbRepository.fetch_parent(note: parent!)
      }
      return previous ?? note
    }
  }
}
