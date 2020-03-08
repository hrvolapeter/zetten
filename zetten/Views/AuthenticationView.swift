//
//  SignInView.swift
//  zetten
//
//  Created by Peter Hrvola on 08/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import Resolver
import SwiftUI

// MARK: Create account
/// Used to generate view for creating new account
/// 
/// Accounts are created in Firebase
struct CreateAccountView: View {
  @State var email: String = ""
  @State var password: String = ""
  @State var loading = false
  @State var error: Error?

  @Injected var authenticationService: AuthenticationService

  func createAccount() {
    logger.debug("Signup with \(email)")
    loading = true
    error = nil
    authenticationService.signUp(email: email, password: password) { (_, err) in
      self.loading = false
      self.error = err
      if err != nil {
        logger.error("Signup error:\(String(describing: err))")
      }
    }
  }

  var body: some View {
    VStack {
      Text("Create an account")
        .font(.title)
      TextField("Email", text: $email)
        .autocapitalization( /*@START_MENU_TOKEN@*/.none /*@END_MENU_TOKEN@*/)
      SecureField("Password", text: $password)
        .autocapitalization(.none)
      if error != nil {
        ErrorBox(
          title: "Error creating account",
          description: String(describing: error?.localizedDescription)
        )
      }
      Button(
        "Create",
        action: createAccount
      ).disabled(loading)

      Divider()

      Text("An account will allow you to save and access notes across devices.")
        .font(.footnote)
        .foregroundColor(.gray)
      Spacer()
    }.padding()
  }
}

// MARK: Login
/// Used to generate view for user signin.
/// Login is performed again Firebase authentication with Firebase local user/password.
/// Firebase Authentication can send welcome, reset password mails and store credentials safely
struct LoginView: View {
  @State var email: String = ""
  @State var password: String = ""
  @State var loading = false
  @State var error: Error?

  @Injected var authenticationService: AuthenticationService

  func logIn() {
    logger.debug("Login with: \(email)")
    loading = true
    error = nil
    authenticationService.signIn(email: email, password: password) { (_, err) in
      self.loading = false
      self.error = err
      if err != nil {
        logger.error("Login error: \(String(describing: err))")
      }
    }
  }

  var body: some View {
    NavigationView {
      VStack {
        Text("Login")
          .font(.title)
        TextField("Email", text: $email)
          .autocapitalization(.none)
        SecureField("Password", text: $password)
          .autocapitalization(.none)
        if error != nil {
          ErrorBox(
            title: "Error login in",
            description: String(describing: error?.localizedDescription)
          )
        }
        Button(
          "Login",
          action: logIn
        ).disabled(loading)

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

struct CreateAccountView_Previews: PreviewProvider {
  static var previews: some View {
    CreateAccountView()
  }
}
