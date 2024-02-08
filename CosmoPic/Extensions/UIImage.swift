//
//  UIImage.swift
//  CosmoPic
//
//  Created by Jan Armbrust on 07.02.24.
//

import Foundation
import UIKit

extension UIImage {
  @MainActor
  func downsampledData(to maxSize: CGSize, scale: CGFloat) -> Data? {
    let aspectWidth = maxSize.width / size.width
    let aspectHeight = maxSize.height / size.height
    let aspectRatio = min(aspectWidth, aspectHeight)

    let scaledSize = CGSize(width: size.width * aspectRatio * scale, height: size.height * aspectRatio * scale)

    UIGraphicsBeginImageContextWithOptions(scaledSize, false, scale)
    draw(in: CGRect(origin: .zero, size: scaledSize))
    let downsampledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    let compressedImageData = downsampledImage?
      .jpegData(compressionQuality: 0.8) // Adjust the compression quality as needed
    return compressedImageData
  }
}
