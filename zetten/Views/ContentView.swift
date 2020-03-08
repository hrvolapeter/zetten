//
//  ContentView.swift
//  zetten
//
//  Created by Peter Hrvola on 08/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import Resolver
import SwiftUI

/// Main view of the application
///
/// View decides if user should be redirected to authentication based on presence of user info in the Authentication service
// Authentication service is Injected using DependencyInjector Resolver
// Resolver's alternative syntax is used to allow detecting changes in the Service
struct ContentView: View {
  @ObservedObject var authenticationService: AuthenticationService = Resolver.resolve()

  var body: some View {
    Group {
      if authenticationService.user == nil {
        LoginView()
      } else {
        NoteListView()
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
