//
//  SessionStore.swift
//  zetten
//
//  Created by Peter Hrvola on 08/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import Firebase

/// Wrapper around Firebase auth services
class AuthenticationService: ObservableObject {
  @Published var user: User?
  var handle: AuthStateDidChangeListenerHandle?

  init() {
    handle = Auth.auth().addStateDidChangeListener { (_, user) in
      if let user = user {
        logger.event("Got user: \(user.uid)")
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
