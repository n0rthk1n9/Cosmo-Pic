//
//  HistoryView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 24.11.23.
//

import SwiftUI

struct HistoryView: View {
  @StateObject private var viewModel = HistoryViewModel()
  @State private var showAlert = false
  @Environment(\.openWindow) private var openWindow

  private var sortedHistory: [Photo] {
    viewModel.history.sorted { $0.date > $1.date }
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
      .padding()
      .navigationTitle("Photo History")
    }
    .alert(isPresented: $showAlert) {
      Alert(
        title: Text("Error"),
        message: Text(viewModel.error?.localizedDescription ?? "An unknown error occurred"),
        dismissButton: .default(Text("Ok"))
      )
    }
    .task {
      await viewModel.getHistory()
      checkAndPrepareErrorAlert()
    }
    .accessibilityIdentifier("history-list")
  }

  private var historyListView: some View {
    List(sortedHistory, id: \.title) { photo in
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

  func checkAndPrepareErrorAlert() {
    if let urlError = viewModel.error as? URLError, urlError.code == .cancelled {
      showAlert = false
    } else if viewModel.error != nil {
      showAlert = true
    }
  }
}
