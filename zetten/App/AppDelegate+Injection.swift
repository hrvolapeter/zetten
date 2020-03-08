//
//  AppDelegate+Injection.swift
//  zetten
//
//  Created by Peter Hrvola on 12/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import Foundation
import Resolver

extension Resolver: ResolverRegistering {
  public static func registerAllServices() {
    register { AuthenticationService() }.scope(application)
    register { DatabaseRepository() }.scope(application)
    register { FirestoreNoteRepository() }.scope(application)
  }
}
