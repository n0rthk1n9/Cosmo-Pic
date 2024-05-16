//
//  FavoritesListSectionHeader.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 16.05.24.
//

import SwiftUI

struct FavoritesListSectionHeader: View {
  @State var title: String
  @Binding var isOn: Bool
  @State var onLabel: String
  @State var offLabel: String

  var body: some View {
    Button(action: {
      withAnimation {
        isOn.toggle()
      }
    }, label: {
      if isOn {
        Text(onLabel)
      } else {
        Text(offLabel)
      }
    })
    .font(Font.caption)
    .foregroundColor(.accentColor)
    .frame(maxWidth: .infinity, alignment: .trailing)
    .overlay(
      Text(title),
      alignment: .leading
    )
  }
}

#Preview {
  FavoritesListSectionHeader(title: "Section 1", isOn: .constant(true), onLabel: "Hide", offLabel: "Show")
}
