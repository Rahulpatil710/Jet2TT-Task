//
//  ImageCache.swift
//  Jet2TT
//
//  Created by Rahul Patil on 11/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

import Foundation
import UIKit

// Declares in-memory image cache
protocol ImageCacheType: class {
    // Returns the image associated with a given url
    func image(for url: URL) -> UIImage?
    // Inserts the image of the specified url in the cache
    func insertImage(_ image: UIImage?, for url: URL)
    // Removes the image of the specified url in the cache
    func removeImage(for url: URL)
    // Removes all images from the cache
    func removeAllImages()
    // Accesses the value associated with the given key for reading and writing
    subscript(_ url: URL) -> UIImage? { get set }
}


final class ImageCache {
    private lazy var imageCache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = config.countLimit
        return cache
    }()
    
    private let config: Config
    struct Config {
        // We limit the cache size with the maximum number of objects and the total cost, such as the size in bytes of all images.
        let countLimit: Int
        let memoryLimit: Int

        static let defaultConfig = Config(countLimit: 100, memoryLimit: 1024 * 1024 * 100) // 1000 MB
    }
    private init(config: Config = Config.defaultConfig) {
        self.config = config
    }
    static let shared = ImageCache()
}

extension ImageCache: ImageCacheType {
    func insertImage(_ image: UIImage?, for url: URL) {
        guard let image = image else { return removeImage(for: url) }
        imageCache.setObject(image, forKey: url as NSURL)
    }

    func removeImage(for url: URL) {
        imageCache.removeObject(forKey: url as NSURL)
    }
    
    func removeAllImages() {
        imageCache.removeAllObjects()
    }
    
    func image(for url: URL) -> UIImage? {
        guard let image = imageCache.object(forKey: url as NSURL) else { return nil }
        return image
    }
}

extension ImageCache {
    subscript(_ key: URL) -> UIImage? {
        get {
            return image(for: key)
        }
        set {
            return insertImage(newValue, for: key)
        }
    }
}
