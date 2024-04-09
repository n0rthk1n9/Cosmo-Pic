//
//  FavoritesWidget.swift
//  FavoritesWidget
//
//  Created by Jan Armbrust on 16.03.24.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
  let viewModel: FavoritesViewModel

  var currentPhoto: UIImage? {
    guard !viewModel.favorites.isEmpty else { return nil }

    let sharedDefaults = UserDefaults(suiteName: "group.dev.xbow.Cosmo-Pic")
    var currentIndex = sharedDefaults?.integer(forKey: "currentIndex") ?? 0
    let totalFavoritesCount = viewModel.favorites.count
    sharedDefaults?.set(totalFavoritesCount, forKey: "totalFavoritesCount")

    if currentIndex < 0 || currentIndex >= totalFavoritesCount {
      currentIndex = 0
      sharedDefaults?.set(currentIndex, forKey: "currentIndex")
    }

    let photo = viewModel.favorites[currentIndex]

    if let localFilenameThumbnail = photo.localFilenameThumbnail {
      let url = FileManager.localFileURL(for: localFilenameThumbnail)
      if let imageData = try? Data(contentsOf: url) {
        return UIImage(data: imageData)
      }
    } else if let hdUrl = photo.hdURL, let imageData = try? Data(contentsOf: hdUrl) {
      return UIImage(data: imageData)
    }
    return nil
  }

  func placeholder(in _: Context) -> SimpleEntry {
    viewModel.loadFavorites()
    return SimpleEntry(date: Date(), photo: currentPhoto)
  }

  func getSnapshot(in _: Context, completion: @escaping (SimpleEntry) -> Void) {
    viewModel.loadFavorites()
    let entry = SimpleEntry(date: Date(), photo: currentPhoto)
    completion(entry)
  }

  func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    viewModel.loadFavorites()
    var entries: [SimpleEntry] = []

    let currentDate = Date()
    for hourOffset in 0 ..< 5 {
      let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
      let entry = SimpleEntry(date: entryDate, photo: currentPhoto)
      entries.append(entry)
    }

    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
  }
}

struct SimpleEntry: TimelineEntry {
  let date: Date
  let photo: UIImage?
}

struct FavoritesWidgetEntryView: View {
  var entry: Provider.Entry

  var body: some View {
    if let photo = entry.photo {
      VStack {
        Spacer()
        HStack {
          Spacer()
          Button(intent: ShowNewFavoritesPhotoIntent(showPreviousPhoto: true)) {
            Image(systemName: "arrow.left.circle")
              .padding()
              .foregroundColor(.blue)
              .background(
                Circle()
                  .fill(Material.ultraThinMaterial)
              )
          }.buttonStyle(.plain)
          Button(intent: ShowNewFavoritesPhotoIntent(showPreviousPhoto: false)) {
            Image(systemName: "arrow.right.circle")
              .padding()
              .foregroundColor(.blue)
              .background(
                Circle()
                  .fill(Material.ultraThinMaterial)
              )
          }.buttonStyle(.plain)
        }
      }
    } else {
      Text("Add some favorites in the app")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
  }
}

struct FavoritesWidget: Widget {
  let kind: String = "FavoritesWidget"
  let viewModel = FavoritesViewModel()

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider(viewModel: viewModel)) { entry in
      FavoritesWidgetEntryView(entry: entry)
        .containerBackground(for: .widget) {
          if let photo = entry.photo {
            Image(uiImage: photo)
              .resizable()
              .scaledToFill()
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          }
        }
    }
    .configurationDisplayName("Favorites Widget")
    .description("Add your favorites right to your homescreen.")
  }
}

// #Preview(as: .systemSmall) {
//  FavoritesWidget()
// } timeline: {
//  SimpleEntry(date: .now, emoji: "😀")
//  SimpleEntry(date: .now, emoji: "🤩")
// }
