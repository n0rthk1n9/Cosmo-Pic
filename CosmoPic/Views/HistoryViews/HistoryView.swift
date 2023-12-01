//
//  HistoryView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import SwiftUI

struct HistoryView: View {
  @EnvironmentObject var dataStore: DataStore

  private var sortedHistory: [Photo] {
    dataStore.history.sorted { $0.date > $1.date }
  }

  var body: some View {
    NavigationStack {
      if sortedHistory.isEmpty && !dataStore.isLoadingHistory {
        ContentUnavailableView("No Data available", systemImage: "x.circle")
      } else {
        historyListView
      }
    }
    .alert(
      "Error",
      isPresented: $dataStore.errorIsPresented,
      presenting: dataStore.error,
      actions: { _ in Button("Ok") {} },
      message: { error in Text(error.localizedDescription) }
    )
    .navigationTitle("Photo History")
    .overlay(loadingOverlay)
    .task {
      await dataStore.getHistory()
    }
    .accessibilityIdentifier("history-list")
  }

  private var historyListView: some View {
    List(sortedHistory, id: \.title) { photo in
      NavigationLink(destination: PhotoDetailView(photo: photo)) {
        HistoryRowView(photo: photo)
      }
    }
  }

  @ViewBuilder private var loadingOverlay: some View {
    if dataStore.isLoadingHistory {
      VStack {
        ProgressView()
          .padding(.bottom)
        ProgressView(value: Double(dataStore.loadedHistoryElements), total: Double(dataStore.totalHistoryElements))
          .padding(.bottom)
        Text("\(dataStore.loadedHistoryElements) / \(dataStore.totalHistoryElements)")
      }
      .padding()
    }
  }
}
