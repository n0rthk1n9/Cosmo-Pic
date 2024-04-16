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

  var deepLinkToCurrentPhoto: URL? {
    guard !viewModel.favorites.isEmpty else { return nil }

    let sharedDefaults = UserDefaults(suiteName: "group.dev.xbow.Cosmo-Pic")
    var currentIndex = sharedDefaults?.integer(forKey: "currentIndex") ?? 0
    let totalFavoritesCount = viewModel.favorites.count
    sharedDefaults?.set(totalFavoritesCount, forKey: "totalFavoritesCount")

    if currentIndex < 0 || currentIndex >= totalFavoritesCount {
      currentIndex = 0
      sharedDefaults?.set(currentIndex, forKey: "currentIndex")
    }
    let deepLinkBase = "cosmopic://Favorites/"
    let deepLinkDetail = viewModel.favorites[currentIndex].title.replacingOccurrences(of: " ", with: "%20")
    let deeplinkURL = URL(string: deepLinkBase + deepLinkDetail)

    if let correctDeeplinkURL = deeplinkURL {
      return correctDeeplinkURL
    }

    return nil
  }

  func placeholder(in _: Context) -> FavoritesEntry {
    viewModel.loadFavorites()
    return FavoritesEntry(date: Date(), photo: currentPhoto, deepLink: nil)
  }

  func getSnapshot(in _: Context, completion: @escaping (FavoritesEntry) -> Void) {
    viewModel.loadFavorites()
    let entry = FavoritesEntry(date: Date(), photo: currentPhoto, deepLink: deepLinkToCurrentPhoto)
    completion(entry)
  }

  func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    viewModel.loadFavorites()
    var entries: [FavoritesEntry] = []

    let currentDate = Date()
    let entry = FavoritesEntry(date: currentDate, photo: currentPhoto, deepLink: deepLinkToCurrentPhoto)
    entries.append(entry)

    let timeline = Timeline(entries: entries, policy: .never)
    completion(timeline)
  }
}

struct FavoritesEntry: TimelineEntry {
  let date: Date
  let photo: UIImage?
  let deepLink: URL?
}

struct FavoritesWidgetButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .labelStyle(.iconOnly)
      .symbolVariant(.fill.circle)
      .imageScale(.large)
      .font(.system(size: 32, weight: .bold))
      .foregroundStyle(.thickMaterial.opacity(configuration.isPressed ? 0.66 : 1))
      .frame(width: 44, height: 44)
  }
}

struct FavoritesWidgetEntryView: View {
  var entry: Provider.Entry

  var body: some View {
    if entry.photo != nil {
      VStack {
        Spacer()
        HStack {
          Spacer()
          Button(intent: ShowNewFavoritesPhotoIntent(showPreviousPhoto: true)) {
            Label("Previous", systemImage: "chevron.backward")
          }
          Button(intent: ShowNewFavoritesPhotoIntent(showPreviousPhoto: false)) {
            Label("Next", systemImage: "chevron.forward")
          }
        }
        .buttonStyle(FavoritesWidgetButtonStyle())
      }
      .widgetURL(entry.deepLink)
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

#Preview(as: .systemSmall) {
  FavoritesWidget()
} timeline: {
  FavoritesEntry(date: .now, photo: nil, deepLink: nil)
}
