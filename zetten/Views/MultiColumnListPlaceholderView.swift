//
//  ListDetailiPad.swift
//  zetten
//
//  Created by Peter Hrvola on 15/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import SwiftUI

struct MultiColumnListPlaceholderView: View {
  var body: some View {
    VStack {
      Spacer()
      Text("Notes")
        .font(.largeTitle)
        .fontWeight(.thin)
        .foregroundColor(Color.gray)
      Spacer()
    }
  }
}

struct ListDetailiPad_Previews: PreviewProvider {
  static var previews: some View {
    MultiColumnListPlaceholderView()
  }
}
