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

  var randomPhoto: UIImage? {
    guard !viewModel.favorites.isEmpty else { return nil }
    let randomIndex = Int.random(in: 0 ..< viewModel.favorites.count)
    let photo = viewModel.favorites[randomIndex]

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
    SimpleEntry(date: Date(), photo: randomPhoto)
  }

  func getSnapshot(in _: Context, completion: @escaping (SimpleEntry) -> Void) {
    let entry = SimpleEntry(date: Date(), photo: randomPhoto)
    completion(entry)
  }

  func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    var entries: [SimpleEntry] = []

    let currentDate = Date()
    for hourOffset in 0 ..< 5 {
      let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
      let entry = SimpleEntry(date: entryDate, photo: randomPhoto)
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
      Image(uiImage: photo)
        .resizable()
        .scaledToFit()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    } else {
      Text("Add some favorites in the app")
    }
  }
}

struct FavoritesWidget: Widget {
  let kind: String = "FavoritesWidget"
  let viewModel = FavoritesViewModel()

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider(viewModel: viewModel)) { entry in
      if #available(iOS 17.0, *) {
        FavoritesWidgetEntryView(entry: entry)
          .containerBackground(.fill.tertiary, for: .widget)
      } else {
        FavoritesWidgetEntryView(entry: entry)
          .padding()
          .background()
      }
    }
    .configurationDisplayName("My Widget")
    .description("This is an example widget.")
  }
}

// #Preview(as: .systemSmall) {
//  FavoritesWidget()
// } timeline: {
//  SimpleEntry(date: .now, emoji: "😀")
//  SimpleEntry(date: .now, emoji: "🤩")
// }
