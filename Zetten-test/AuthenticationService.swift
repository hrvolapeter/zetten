//
//  AuthenticationService.swift
//  Zetten-test
//
//  Created by Peter Hrvola on 22/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import Foundation
import Firebase

class AuthenticationService: ObservableObject {
  @Published var user: User?
  var cancellable: AuthStateDidChangeListenerHandle?

  init() {
    cancellable = Auth.auth().addStateDidChangeListener { (_, user) in
      if let user = user {
        self.user = User(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName
        )
      } else {
        self.user = nil
      }
    }
  }

  func signUp(
    email: String,
    password: String,
    handler: @escaping AuthDataResultCallback
  ) {
    Auth.auth().createUser(withEmail: email, password: password, completion: handler)
  }

  func signIn(
    email: String,
    password: String,
    handler: @escaping AuthDataResultCallback
  ) {
    Auth.auth().signIn(withEmail: email, password: password, completion: handler)
  }

  func signOut() throws {
    try Auth.auth().signOut()
    self.user = nil
  }
}
