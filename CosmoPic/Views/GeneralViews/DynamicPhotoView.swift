//
//  DynamicPhotoView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 01.12.23.
//

import SwiftUI

struct DynamicPhotoView: View {
  @StateObject private var viewModel = PhotoViewModel()

  let photo: Photo
  var size: CGSize? = .init(width: 100, height: 100)

  var photoURL: URL? {
    if let localFilename = photo.localFilename {
      return FileManager.localFileURL(for: localFilename)
    } else if let hdUrl = photo.hdURL {
      return hdUrl
    } else {
      return nil
    }
  }

  var body: some View {
    if let size {
      ZStack(alignment: .topTrailing) {
        ZStack(alignment: .bottomTrailing) {
          AsyncImage(
            url: photoURL,
            content: { image in
              image
                .resizable()
            },
            placeholder: {
              ProgressView()
            }
          )
          .scaledToFill()
          .ignoresSafeArea()
          .frame(maxWidth: size.width, maxHeight: size.height * 0.60)

          Button(
            action: {
              Task {
                await viewModel.saveImage(from: photoURL)
              }
            }, label: {
              VStack {
                if viewModel.saveCompleted {
                  Image(systemName: "checkmark")
                    .font(.title2)
                    .foregroundColor(.green)
                } else {
                  Label(
                    title: {
                      Text("Save")
                    },
                    icon: {
                      Image(systemName: "square.and.arrow.down")
                    }
                  )
                  .font(.title2)
                  .foregroundColor(viewModel.isSaving ? .gray : .white)
                }
              }
              .frame(width: UIScreen.main.bounds.width / 4)
              .padding()
              .background(.thinMaterial)
              .cornerRadius(10)
              .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 20))
            }
          )
          .buttonStyle(PlainButtonStyle())
          .disabled(viewModel.isSaving || viewModel.saveCompleted)
        }

        FavoriteButtonView(photo: photo)
      }
      .showCustomAlert(alert: $viewModel.error)
    }
  }
}

#Preview {
  DynamicPhotoView(photo: .allProperties)
    .environmentObject(FavoritesViewModel())
}
