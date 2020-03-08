//
//  InlineAlert.swift
//  zetten
//
//  Created by Peter Hrvola on 08/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import SwiftUI

struct ErrorBox: View {
  var title: String
  var description: String?

  var body: some View {
    HStack() {
      Image(systemName: "exclamationmark.triangle.fill")
        .foregroundColor(.white)
      VStack {
        Text(self.title)
          .foregroundColor(.white)
          .fontWeight(.bold)

        if self.description != nil {
          Text(self.description!)
            .foregroundColor(.white)
        }
      }
    }.padding()
      .background(Color.red)
      .cornerRadius(3)

  }
}

struct ErrorBox_Previews: PreviewProvider {
  static var previews: some View {
    ErrorBox(
      title: "Very serious error without solution",
      description:
        "This happend because the Moon has covered Saturn resulting in creating gas capsules flipping bites on your cpu"
    )
  }
}
