import Combine
//
//  DatabaseRepository.swift
//  zetten
//
//  Created by Peter Hrvola on 16/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//
import GRDB
import Resolver

/// Local database with Notes used to perform full text and to display notes
class DatabaseRepository {
  @Injected var firestoreNoteRepository: FirestoreNoteRepository
  let notesHasChanged = ObservableObjectPublisher()

  private var dbQueue: DatabaseQueue!
  private var cancellables = Set<AnyCancellable>()

  init() {
    let databaseURL = try! FileManager.default
      .url(for: .applicationDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
      .appendingPathComponent("db.sqlite")
    dbQueue = try! DatabaseQueue(path: databaseURL.path)
    try! migrator.migrate(dbQueue)

    // Start listening for changes from firestore
    firestoreNoteRepository.$notes
      .dropFirst()
      .sink(receiveValue: handleChange)
      .store(in: &cancellables)
  }

  /// Handles change from firestore
  ///
  /// Performs diff between Firestore and local db and resolves changes
  private func handleChange(notes: [Note]) {
    logger.debug("Received \(notes.count) changes from Firestore")
    try! dbQueue.write { db in
      let localNotes = try! Note.fetchAll(db)
      var localNotesSet = Set(localNotes)
      let noteFirestore = Set(notes)

      localNotesSet.subtract(noteFirestore)
      logger.debug("Removing \(localNotes.count) notes not present in Firestore update")
      for note in localNotesSet {
        try! note.delete(db)
      }

      var notes = notes
      for note in notes.enumerated() {
        try! notes[note.0].save(db)
      }
    }
    notesHasChanged.send()
  }

  private var migrator: DatabaseMigrator {
    var migrator = DatabaseMigrator()

    migrator.eraseDatabaseOnSchemaChange = true
    logger.debug("Performing migrations")
    migration_01(migrator: &migrator)
    logger.debug("Migrations done")
    return migrator
  }

  /// Perform full text search
  ///
  /// Full text query on title and content, empty matches all
  /// - Parameters:
  ///     - query: query to search
  func fetch(query q: String) throws -> [Note] {
    logger.debug("Query local db with: \(q)")
    return try dbQueue.read { db in
      if q.isEmpty {
        return try Note.order(sql: "createdTime DESC").fetchAll(db)
      } else {
        return try Note.fetchAll(
          db,
          sql: """
            SELECT note.*
            FROM note
            JOIN note_ft ON note_ft.rowid = note.rowid
            WHERE note_ft MATCH '{title tags content}: "' || ? || '"'
            AND rank MATCH 'bm25(10.0, 5.0, 1.0)'
            ORDER BY rank
            """,
          arguments: [q])
      }
    }
  }

  func fetch(id: String) throws -> Note? {
    try dbQueue.read { db in
      try Note.fetchOne(db, key: id)
    }
  }

  func fetch_parent(note: Note) throws -> Note? {
    logger.debug("Get parents for")
    return try dbQueue.read { db in
      try Note.filter(literal: "id = \(note.parentId ?? "empty")").fetchOne(db)
    }
  }

  func fetch_children(note: Note) throws -> [Note] {
    logger.debug("Get children for")
    return try dbQueue.read { db in
      try Note.filter(literal: "parentId = \(note.id)").fetchAll(db)
    }
  }

  /// Update notes in local database
  func update(notes: inout [Note]) throws {
    logger.debug("Updating localdb with \(notes.count) notes")
    try dbQueue.write { db in
      for note in notes {
        try note.update(db)
      }

    }
  }

  /// Remove note from local database
  func remove(note: Note) throws {
    logger.debug("Removing note from db \(note.id) \(note.title)")
    try dbQueue.write { db in
      if try note.exists(db) {
        try note.delete(db)
      }
    }
  }
}

// MARK: Migrations
func migration_01(migrator: inout DatabaseMigrator) {
  migrator.registerMigration(#function) { db in
    try db.create(table: "note") { t in
      t.column("id", .text).notNull().primaryKey()
      t.column("createdTime", .datetime).notNull()
      t.column("userId", .text).notNull().indexed()
      t.column("title", .text).notNull()
      t.column("content", .text).notNull()
      t.column("deleted", .datetime)
      t.column("parentId", .text).indexed()
      t.column("tags", .text).notNull()
    }

    try db.create(virtualTable: "note_ft", using: FTS5()) { t in
      t.synchronize(withTable: "note")
      t.tokenizer = .porter(wrapping: .unicode61())
      t.column("title")
      t.column("content")
      t.column("tags")
      t.prefixes = [2, 8]
    }

  }
}
