//
//  ImageCache.swift
//  Yakssok
//
//  Created by 김사랑 on 8/22/25.
//

import UIKit

final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, NSData>()

    private init() {}

    func prefetch(_ url: URL) async {
        if cache.object(forKey: url.absoluteString as NSString) != nil {
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            cache.setObject(data as NSData, forKey: url.absoluteString as NSString, cost: data.count)
        } catch {
            print("Image prefetch failed:", error)
        }
    }

    func image(for url: URL) -> UIImage? {
        if let data = cache.object(forKey: url.absoluteString as NSString) {
            return UIImage(data: data as Data)
        }
        return nil
    }
}
