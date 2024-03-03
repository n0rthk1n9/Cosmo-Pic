//
//  TodayPhotoView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 03.03.24.
//

import SwiftUI

struct TodayPhotoView: View {
  @EnvironmentObject var favoritesViewModel: FavoritesViewModel

  let photo: Photo

  var body: some View {
    VStack(alignment: .center) {
      DynamicPhotoView(photo: photo)

      Text(photo.title)
        .padding([.top, .trailing, .leading])
        .font(.title2)
    }
  }
}

#Preview {
  TodayPhotoView(photo: .allProperties)
    .environmentObject(FavoritesViewModel())
}
