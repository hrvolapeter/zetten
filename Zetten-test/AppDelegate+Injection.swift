//
//  AppDelegate+Injection.swift
//  Zetten-test
//
//  Created by Peter Hrvola on 22/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import Foundation
import Resolver

extension Resolver: ResolverRegistering {
  public static func registerAllServices() {
    register { AuthenticationService() }.scope(application)
  }
}
