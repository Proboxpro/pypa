//
//  UIImage+MergeBySide.swift
//  Boxx
//
//  Created by Максим Алексеев  on 16.03.2024.
//

import Foundation
import UIKit

extension UIImage {
    
    static func downloaded(from url: URL) async -> UIImage {
        return await withCheckedContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data1 = data, error == nil,
                    let image = UIImage(data: data1)
                else { return }
                
                continuation.resume(returning: image)
            }.resume()
        }
    }
    
    func mergedSideBySide(with otherImage: UIImage) -> UIImage? {
        let mergedWidth = self.size.width + otherImage.size.width
        let mergedHeight = max(self.size.height, otherImage.size.height)
        let mergedSize = CGSize(width: mergedWidth, height: mergedHeight)
        UIGraphicsBeginImageContext(mergedSize)
        self.draw(in: CGRect(x: 0, y: 0, width: mergedWidth, height: mergedHeight))
        otherImage.draw(in: CGRect(x: self.size.width, y: 0, width: mergedWidth, height: mergedHeight))
        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return mergedImage
    }

    func compressed(to quality: CGFloat) -> UIImage? {
        guard let data = self.jpegData(compressionQuality: quality) else { return nil }
        return UIImage(data: data)
    }

    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        self.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
