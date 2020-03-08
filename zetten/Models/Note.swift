//
//  Note.swift
//  zetten
//
//  Created by Peter Hrvola on 08/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import GRDB

struct Note: Codable, Identifiable {
  var id: String = UUID().uuidString
  var title: String
  var createdTime = Timestamp()
  var content: String
  var userId: String?
  var deleted: Timestamp?
  var parentId: String?
  var tags: [String]
}

extension Note: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(content)
    hasher.combine(title)
    hasher.combine(tags)
  }
}

extension Note: MutablePersistableRecord {
  static let databaseTableName = "note"

  func encode(to container: inout PersistenceContainer) {
    container["id"] = id
    container["title"] = title
    container["createdTime"] = createdTime.seconds
    container["content"] = content
    container["userId"] = userId
    container["deleted"] = deleted?.seconds
    container["parentId"] = parentId
    let encoder = JSONEncoder()
    container["tags"] = try! encoder.encode(tags)

  }
}

extension Note: FetchableRecord {
  init(row: Row) {
    id = row["id"]
    title = row["title"]
    createdTime = Timestamp(seconds: row["createdTime"], nanoseconds: 0)
    content = row["content"]
    userId = row["userId"]
    parentId = row["parentId"]
    let decoder = JSONDecoder()
    tags = try! decoder.decode([String].self, from: row["tags"])

    if let deletedTime = row["deleted"] {
      deleted = Timestamp(seconds: deletedTime as! Int64, nanoseconds: 0)
    } else {
      deleted = nil
    }
  }
}

#if DEBUG
  // Note for previews
  let notePreview = Note(
    id: "123", title: "title", createdTime: Timestamp(), content: "VEry long test",
    userId: "userid", deleted: nil, parentId: "12345",
    tags: [
      "tag", "very long tag", "some more tag", "annoying tags", "and even more", "super long tags",
    ])
#endif
