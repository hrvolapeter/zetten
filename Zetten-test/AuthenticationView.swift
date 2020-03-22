//
//  AuthenticationView.swift
//  Zetten-test
//
//  Created by Peter Hrvola on 22/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import SwiftUI
import Resolver

struct LoginView: View {
    @State var email: String = ""
    @State var password: String = ""
    
    @Injected var authenticationService: AuthenticationService
    
    var body: some View {
        NavigationView {
        VStack {
            Text("Login")
                .font(.title)
            TextField("Email", text: $email)
                .autocapitalization(.none)
            SecureField("Password", text: $password)
                .autocapitalization(.none)
            Button(
                "Login",
                action: {
                    self.authenticationService.signIn(email: self.email, password: self.password,  handler: {res,err in
                               print(res)
                               print(err)
                             })
            }
            )
            
            Divider()
            NavigationLink(destination: CreateAccountView()) {
                Text("Don't have an account?").foregroundColor(.gray)
                Text("Create an account")
            }.font(.footnote)

            Spacer()
        }.padding()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

struct CreateAccountView: View {
  @State var email: String = ""
  @State var password: String = ""
    
  @Injected var authenticationService: AuthenticationService

  var body: some View {
    VStack {
      Text("Create an account")
        .font(.title)
      TextField("Email", text: $email)
        .autocapitalization( /*@START_MENU_TOKEN@*/.none /*@END_MENU_TOKEN@*/)
      SecureField("Password", text: $password)
        .autocapitalization(.none)
      Button(
        "Create",
        action: {
          self.authenticationService.signUp(email: self.email, password: self.password, handler: {res,err in
            print(res)
            print(err)
          })
        }
      )

      Divider()

      Text("An account allows to save and access notes across devices.")
        .font(.footnote)
        .foregroundColor(.gray)
      Spacer()
    }.padding()
  }
}

struct CreateAccountView_Previews: PreviewProvider {
  static var previews: some View {
    CreateAccountView()
  }
}
