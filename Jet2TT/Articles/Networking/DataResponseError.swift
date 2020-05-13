//
//  DataResponseError.swift
//  Jet2TT
//
//  Created by Rahul Patil on 12/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

import Foundation

enum DataResponseError: Error {
    case network
    case decoding
    case noConnection
    
    var reason: String {
        switch self {
        case .network:
            return "An error occurred while fetching data"
        case .decoding:
            return "An error occurred while decoding data"
        case .noConnection:
            return "Don't have Internet connection"
        }
    }
}
