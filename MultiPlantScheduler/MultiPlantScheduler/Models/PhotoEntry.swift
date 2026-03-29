import SwiftData
import UIKit
import Foundation

/// A timestamped photo entry for tracking plant growth over time
@Model
final class PhotoEntry {
    var id: UUID = UUID()
    var captureDate: Date = Date.now
    var photoData: Data?
    var notes: String?
    var plant: Plant?

    init(
        photoData: Data?,
        captureDate: Date = Date.now,
        notes: String? = nil,
        plant: Plant? = nil
    ) {
        self.id = UUID()
        self.captureDate = captureDate
        self.photoData = PhotoEntry.processImage(photoData)
        self.notes = notes
        self.plant = plant
    }

    /// Resize and compress image data to max 1024px dimension at 0.5 quality
    static func processImage(_ data: Data?) -> Data? {
        guard let data = data,
              let image = UIImage(data: data) else { return data }

        let maxDimension: CGFloat = 1024
        let size = image.size

        if size.width <= maxDimension && size.height <= maxDimension {
            return image.jpegData(compressionQuality: 0.5)
        }

        let scale: CGFloat
        if size.width > size.height {
            scale = maxDimension / size.width
        } else {
            scale = maxDimension / size.height
        }

        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }

        return resized.jpegData(compressionQuality: 0.5)
    }

    /// SwiftUI Image from photo data
    var photoImage: Image? {
        guard let photoData = photoData,
              let uiImage = UIImage(data: photoData) else { return nil }
        return Image(uiImage: uiImage)
    }
}

import SwiftUI
