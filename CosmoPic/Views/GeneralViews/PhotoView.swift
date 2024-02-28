//
//  PhotoView.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 28.11.23.
//

import SwiftUI

struct PhotoView: View {
  @State private var isSaving = false
  @State private var saveCompleted = false

  let url: URL
  var showAsHeroImage: Bool? = false
  var size: CGSize? = .init(width: 100, height: 100)
  let imageSaver = ImageSaverService()

  var body: some View {
    if let showAsHeroImage, let size {
      if showAsHeroImage {
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
              isSaving = true
              Task {
                await imageSaver.saveImage(from: url)
                saveCompleted = true
                isSaving = false
              }
            }, label: {
              VStack {
                if saveCompleted {
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
                  .foregroundColor(isSaving ? .gray : .white)
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
          .disabled(isSaving || saveCompleted)
        }
      } else {
        AsyncImage(url: url) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fit)
        } placeholder: {
          HStack {
            Spacer()
            ProgressView()
              .frame(height: 300)
            Spacer()
          }
        }
        .cornerRadius(20)
        .clipped()
        .padding(.horizontal)
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

  return PhotoView(url: url, showAsHeroImage: true)
}
