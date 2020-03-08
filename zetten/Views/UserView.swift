//
//  UserView.swift
//  zetten
//
//  Created by Peter Hrvola on 14/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import Resolver
import SwiftUI

/// User detail view
struct UserView: View {
  @ObservedObject var authenticationService: AuthenticationService = Resolver.resolve()

  var body: some View {
    VStack {
      Spacer()
      Image(systemName: "person").resizable().frame(width: 120, height: 120)
      Text("Email: \(authenticationService.user?.email ?? "")")
      Spacer()
      Button(action: { try! self.authenticationService.signOut() }) {
        Text("Sign out")
      }
      Spacer()
    }.navigationBarTitle(Text("User"), displayMode: .inline)
  }
}
