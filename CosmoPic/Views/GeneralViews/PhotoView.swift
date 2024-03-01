//
//  PhotoView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 28.11.23.
//

import SwiftUI

struct PhotoView: View {
  @StateObject private var viewModel = PhotoViewModel()

  let photo: Photo
  let url: URL
  var showAsHeroImage: Bool? = false
  var size: CGSize? = .init(width: 100, height: 100)

  var body: some View {
    if let showAsHeroImage, let size {
      if showAsHeroImage {
        ZStack(alignment: .topTrailing) {
          ZStack(alignment: .bottomTrailing) {
            AsyncImage(
              url: url,
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
                  await viewModel.saveImage(from: url)
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

          NewFavoriteButtonView(photo: photo)
        }
        .showCustomAlert(alert: $viewModel.error)
      } else {
        GeometryReader { geometry in
          ZStack(alignment: .topTrailing) {
            AsyncImage(url: url) { image in
              image
                .resizable()
                .aspectRatio(contentMode: .fill)
            } placeholder: {
              HStack {
                Spacer()
                ProgressView()
                  .frame(height: 300)
                Spacer()
              }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .cornerRadius(20)
            .clipped()

            NewFavoriteButtonView(photo: photo)
          }
        }
        .padding(.horizontal, 20)
      }
    }
  }
}

#Preview {
  guard let url =
    URL(
      string: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/1024px-Apple_logo_black.svg.png"
    )
  else {
    return Text("Error creating url")
  }

  return PhotoView(photo: .allProperties, url: url, showAsHeroImage: false)
}
