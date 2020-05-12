//
//  Images.swift
//  Jet2TT
//
//  Created by Rahul Patil on 11/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

import Foundation
import UIKit

enum ImageState {
    case new, downloaded, failed
}

protocol RPImageProtocol {
    var id: String { get }
    var url: URL { get }
    var state: ImageState { get set }
    var imageData: Data? { get set }
    init(_ blogId: String, imageUrl: URL, imageState: ImageState, data: Data?)
}

class RPImage: RPImageProtocol {
    let id: String
    let url: URL
    var state: ImageState
    var imageData: Data?
    
    required init(_ blogId: String, imageUrl: URL, imageState: ImageState = .new, data: Data? = nil) {
        id = blogId
        url = imageUrl
        state = imageState
        imageData = data
    }
}

protocol BlogImageProtocol {
    var profileImage: RPImage? { get set }
    var mediaImage: RPImage? { get set }
    init(_ profile: RPImage?, and media: RPImage?)
}

class BlogImage: BlogImageProtocol {
    var profileImage: RPImage?
    var mediaImage: RPImage?
    
    required init(_ profile: RPImage? = nil, and media: RPImage? = nil) {
        profileImage = profile
        mediaImage = media
    }
}
