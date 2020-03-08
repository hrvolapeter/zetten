//
//  Timestamp.swift
//  zetten
//
//  Created by Peter Hrvola on 20/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//
import FirebaseFirestore

extension Timestamp {
  func getFormattedDate() -> String {
    let dateformat = DateFormatter()
    dateformat.dateStyle = .medium
    return dateformat.string(
      from: .init(timeIntervalSince1970: .init(integerLiteral: self.seconds)))
  }
}
