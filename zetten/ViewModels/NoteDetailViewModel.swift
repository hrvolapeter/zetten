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
        @Injected var db: DatabaseRepository
        
        @Published var note: Note
        @Published var tagsField = ""
        @Published var typeahead = ""
        private var noteHasChanged = false
        private var allTags: Set<String> = []
        
        private var cancellables = Set<AnyCancellable>()
        
        init(note: Note) {
            self.note = note
        }
        
        func onAppear() {
            noteHasChanged = false
            allTags = try! db.fetch_all_tags()
            
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
            
            self.$tagsField.sink { tagSearch in
                var shortened = self.tagsField
                if !shortened.isEmpty {
                    shortened.removeLast()
                }
                // Suggestion algorithm:
                // 1. If query is empty don't return anything
                // 2. If nothing was removed (selection changed) don't return anything
                // 3. If last character of previous query was remove don't return anyhting
                if tagSearch.isEmpty || self.tagsField == tagSearch || tagSearch == shortened {
                    self.typeahead = ""
                    return
                }
                self.typeahead = self.allTags.filter { s in s.lowercased().hasPrefix(tagSearch.lowercased())}.first ?? ""
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
            if (!typeahead.isEmpty) {
                self.note.tags.append(typeahead)
            } else {
                self.note.tags.append(tagsField)
            }
            self.tagsField = ""
            self.typeahead = ""
        }
        
        static func newNote() -> NoteDetailView.ViewModel {
            self.newNote(parentId: nil)
        }
        
        static func newNote(parentId: String?) -> NoteDetailView.ViewModel {
            NoteDetailView.ViewModel(note: .init(title: "", content: "", parentId: parentId, tags: []))
        }
    }
}
