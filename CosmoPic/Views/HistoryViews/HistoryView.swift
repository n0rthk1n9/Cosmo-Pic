//
//  HistoryView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import SwiftUI

struct HistoryView: View {
  @EnvironmentObject var dataStore: DataStore
  @State private var showAlert = false

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
    .alert(isPresented: $showAlert) {
      Alert(
        title: Text("Error"),
        message: Text(dataStore.error?.localizedDescription ?? "An unknown error occurred"),
        dismissButton: .default(Text("Ok"))
      )
    }
    .navigationTitle("Photo History")
    .overlay(loadingOverlay)
    .task {
      await dataStore.getHistory()
      checkAndPrepareErrorAlert()
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
        Spacer()
        Text("Loading 1 Month History")
          .padding(.bottom)
        ProgressView()
          .padding(.bottom)
        ProgressView(value: Double(dataStore.loadedHistoryElements), total: Double(dataStore.totalHistoryElements))
          .padding(.bottom)
        Text("\(dataStore.loadedHistoryElements) / \(dataStore.totalHistoryElements)")
        Spacer()
      }
      .padding()
      .background(.thinMaterial)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }

  func checkAndPrepareErrorAlert() {
    if let urlError = dataStore.error as? URLError, urlError.code == .cancelled {
      showAlert = false
    } else if dataStore.error != nil {
      showAlert = true
    }
  }
}
