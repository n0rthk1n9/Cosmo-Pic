//
//  ImageSaverService.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 28.02.24.
//

import UIKit

class ImageSaverService: NSObject {
  func saveImage(from url: URL) async throws {
    let image: UIImage?

    do {
      if url.isFileURL {
        image = UIImage(contentsOfFile: url.path)
      } else {
        image = try await downloadImage(from: url)
      }

      guard let imageToSave = image else {
        throw CosmoPicError.noFileFound
      }

      writeToPhotoAlbum(image: imageToSave)
    } catch {
      throw error
    }
  }

  private func downloadImage(from url: URL) async throws -> UIImage? {
    do {
      let (data, response) = try await URLSession.shared.data(from: url)
      guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw CosmoPicError.invalidResponseCode
      }
      return UIImage(data: data)
    } catch {
      throw error
    }
  }

  func writeToPhotoAlbum(image: UIImage) {
    UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
  }

  @objc func saveCompleted(_: UIImage, didFinishSavingWithError _: Error?, contextInfo _: UnsafeRawPointer) {
    print("Save finished!")
  }
}
