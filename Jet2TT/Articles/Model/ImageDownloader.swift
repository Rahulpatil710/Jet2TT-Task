//
//  ImageDownloader.swift
//  Jet2TT
//
//  Created by Rahul Patil on 11/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

import Foundation
import UIKit

class ImageDownloader: Operation {
    private let image: RPImage
    
    init(_ image: RPImage) {
        self.image = image
    }
    
    override func main() {
        let isReachable = Reachability.shared.isConnectedToNetwork()
        guard isReachable == true else {
            return
        }
        if isCancelled {
            return
        }
        guard let imageData = try? Data(contentsOf: image.url) else {
            return
        }
        if isCancelled {
            return
        }
        if !imageData.isEmpty {
            image.state = .downloaded
            image.imageData = imageData
        } else {
            image.state = .failed
        }
    }
}
