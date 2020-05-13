//
//  DataResponseError.swift
//  Jet2TT
//
//  Created by Rahul Patil on 12/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

import Foundation

enum DataResponseError: Error {
    case decoding
    case error
    case network
    case noConnection
    
    var reason: String {
        switch self {
        case .decoding:
            return "An error occurred while decoding data"
        case .error:
            return "An error occured while fetching blogs"
        case .network:
            return "An error occurred while fetching data"
        case .noConnection:
            return "Don't have Internet connection"
        }
    }
}
