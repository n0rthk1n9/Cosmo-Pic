//
//  HistoryView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import SwiftUI

struct HistoryView: View {
  @StateObject private var viewModel = HistoryViewModel()
  @Environment(\.openWindow)
  private var openWindow

  @State private var searchText = ""

  let suggestions: [String] = [
    "Swift", "SwiftUI", "Obj-C"
  ]

  private var sortedHistory: [Photo] {
    viewModel.history.sorted { $0.date > $1.date }
  }

  var searchResults: [Photo] {
    if searchText.isEmpty {
      return sortedHistory
    } else {
      return sortedHistory.filter { $0.title.contains(searchText)
      }
    }
  }

  var body: some View {
    NavigationStack {
      VStack {
        if viewModel.isLoading {
          loadingOverlay
        } else if !sortedHistory.isEmpty {
          historyListView
        } else {
          ContentUnavailableView("No Data available", systemImage: "x.circle")
            .showCustomAlert(alert: $viewModel.error)
        }
      }
      #if os(visionOS)
      .padding()
      #endif
      .navigationTitle("History 🌌")
    }
    .task {
      await viewModel.getHistory()
    }
    .accessibilityIdentifier("history-list")
    .searchable(text: $searchText, prompt: "Search for an image title")
  }

  private var historyListView: some View {
    List(searchResults, id: \.title) { photo in
      NavigationLink(value: photo) {
        HistoryRowView(photo: photo)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      #if os(visionOS)
      .onTapGesture {
        openWindow(value: photo)
      }
      #endif
    }
    #if !os(visionOS)
    .navigationDestination(for: Photo.self) { photo in
      PhotoDetailView(photo: photo)
    }
    #endif
  }

  private var loadingOverlay: some View {
    VStack {
      Spacer()
      Text("Loading 1 Month History")
        .padding(.bottom)
      ProgressView()
        .padding(.bottom)
      ProgressView(value: Double(viewModel.loadedElements), total: Double(viewModel.totalElements))
        .padding(.bottom)
      Text("\(viewModel.loadedElements) / \(viewModel.totalElements)")
      Spacer()
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

#Preview {
  HistoryView()
}
