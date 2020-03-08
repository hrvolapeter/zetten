//
//  NoteRepository.swift
//  zetten
//
//  Created by Peter Hrvola on 12/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import Combine
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import Resolver

/// Repository handling communication with Firestore
///
/// Rules for firestore:
/// ```
/// rules_version = '2';
/// service cloud.firestore {
///   match /databases/{database}/documents {
///     match /notes/{noteId} {
///       function isSignedIn() {
///         return request.auth.uid != null;
///       }
///       allow read, update: if isSignedIn() && request.auth.uid == resource.data.userId;
///       allow create: if isSignedIn();
///     }
///   }
/// }
/// ```
class FirestoreNoteRepository: ObservableObject {
  @Published var notes = [Note]()
  @Injected var authenticationService: AuthenticationService

  var db = Firestore.firestore()

  var notesPath: String = "notes"
  var userId: String = "unknown"

  private var cancellables = Set<AnyCancellable>()

  init() {
    db.settings.isPersistenceEnabled = true
    authenticationService.$user
      .compactMap { user in
        user?.uid
      }
      .assign(to: \.userId, on: self)
      .store(in: &cancellables)

    authenticationService.$user
      .receive(on: DispatchQueue.main)
      .sink { user in
        logger.info("User changed realoding Firestore data")
        try! self.loadData()
      }
      .store(in: &cancellables)
  }

  private func loadData() throws {
    db.collection(notesPath)
      .whereField("userId", isEqualTo: self.userId)
      .order(by: "createdTime")
      .addSnapshotListener { (querySnapshot, error) in
        if let querySnapshot = querySnapshot {
          logger.debug("Received changes from Firestore")
          let decoder = Firestore.Decoder()
          self.notes = querySnapshot.documents.map { document -> Note in
            var data = document.data()
            if data["tags"] == nil {
              data["tags"] = []
            }
            return try! decoder.decode(Note.self, from: data)
          }.filter { note in note.deleted == nil }
        }
      }
  }

  func save(note: inout Note) throws {
    logger.info("Saving note in Firestore \(note.id) \(note.title)")
    note.userId = self.userId
    let collection = db.collection(notesPath)
    try collection.document(note.id).setData(from: note)
  }

  /// Performs soft delete
  ///
  /// Add curent Timestamp to deleted field, marking time of deletion
  func remove(note: inout Note) throws {
    logger.info("Marking deleted note in Firestore \(note.id) \(note.title)")
    note.deleted = Timestamp()
    try save(note: &note)
  }
}
