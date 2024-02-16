//
//  Binding.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 16.02.24.
//

import SwiftUI

extension Binding where Value == Bool {
  init<T>(value: Binding<T?>) {
    self.init {
      value.wrappedValue != nil
    } set: { newValue in
      if !newValue {
        value.wrappedValue = nil
      }
    }
  }
}
