//
//  HistoryView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import SwiftUI

struct HistoryView: View {
  @EnvironmentObject var dataStore: DataStore
  @StateObject private var viewModel = HistoryViewModel()
  @State private var showAlert = false

  private var sortedHistory: [Photo] {
    viewModel.history.sorted { $0.date > $1.date }
  }

  var body: some View {
    NavigationStack {
      if sortedHistory.isEmpty && !viewModel.isLoading {
        ContentUnavailableView("No Data available", systemImage: "x.circle")
      } else {
        historyListView
      }
    }
    .alert(isPresented: $showAlert) {
      Alert(
        title: Text("Error"),
        message: Text(viewModel.error?.localizedDescription ?? "An unknown error occurred"),
        dismissButton: .default(Text("Ok"))
      )
    }
    .navigationTitle("Photo History")
    .overlay(loadingOverlay)
    .task {
      await viewModel.getHistory()
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
    if viewModel.isLoading {
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
      .background(.thinMaterial)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
  }

  func checkAndPrepareErrorAlert() {
    if let urlError = viewModel.error as? URLError, urlError.code == .cancelled {
      showAlert = false
    } else if viewModel.error != nil {
      showAlert = true
    }
  }
}
