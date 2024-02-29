//
//  CosmoPicAlert.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 16.02.24.
//

import SwiftUI

protocol CosmoPicAlert {
  var title: String { get }
  var subtitle: String? { get }
  var buttons: AnyView { get }
}
