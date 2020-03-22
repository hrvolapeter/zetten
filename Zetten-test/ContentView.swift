//
//  ContentView.swift
//  Zetten-test
//
//  Created by Peter Hrvola on 22/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import SwiftUI
import Resolver

struct ContentView: View {
     @ObservedObject var authenticationService: AuthenticationService = Resolver.resolve()


    var body: some View {
        Group {
            if (authenticationService.user == nil) {
                LoginView()
            } else {
                Text("Signed in")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
