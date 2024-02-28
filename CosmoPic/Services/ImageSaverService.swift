//
//  ImageSaverService.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 28.02.24.
//

import UIKit

class ImageSaverService: NSObject {
  func saveImage(from url: URL) async {
    let image: UIImage?

    if url.isFileURL {
      image = UIImage(contentsOfFile: url.path)
    } else {
      image = await downloadImage(from: url)
    }

    if let imageToSave = image {
      writeToPhotoAlbum(image: imageToSave)
    } else {
      print("Could not load image from URL")
    }
  }

  private func downloadImage(from url: URL) async -> UIImage? {
    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      return UIImage(data: data)
    } catch {
      print("Failed to download image: \(error)")
      return nil
    }
  }

  func writeToPhotoAlbum(image: UIImage) {
    UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
  }

  @objc func saveCompleted(_: UIImage, didFinishSavingWithError _: Error?, contextInfo _: UnsafeRawPointer) {
    print("Save finished!")
  }
}
