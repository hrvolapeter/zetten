//
//  SearchBar.swift
//  zetten
//
//  Created by Peter Hrvola on 14/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//
import SwiftUI

struct SearchBar: UIViewRepresentable {
  @Binding var text: String
  var placeholder: String?

  func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
    let searchBar = UISearchBar(frame: .zero)
    searchBar.delegate = context.coordinator
    searchBar.placeholder = placeholder
    return searchBar
  }

  func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
    uiView.text = text
  }

  func makeCoordinator() -> SearchBar.Cordinator {
    return Cordinator(text: $text)
  }

  class Cordinator: NSObject, UISearchBarDelegate {
    @Binding var text: String

    init(text: Binding<String>) {
      _text = text
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
      text = searchText
    }
  }
}
