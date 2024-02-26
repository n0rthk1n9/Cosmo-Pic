//
//  CheckmarkView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 01.12.23.
//

import SwiftUI

struct CheckmarkView: View {
  @Binding var showCheckmark: Bool

  var body: some View {
    Image(systemName: "checkmark.circle.fill")
      .font(.title)
      .foregroundStyle(.green)
      .padding(.vertical)
      .transition(.opacity)
      .onAppear {
        Task {
          try await Task.sleep(nanoseconds: 1_000_000_000)
          withAnimation {
            showCheckmark = false
          }
        }
      }
  }
}

#Preview {
  CheckmarkView(showCheckmark: .constant(true))
}
