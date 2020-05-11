//
//  PendingOperations.swift
//  Jet2TT
//
//  Created by Rahul Patil on 11/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

import Foundation
import UIKit

protocol PendingOperationsProtocol  {
    var profileDownloadInProgress: [IndexPath: Operation] { get set }
    var profileDownloadQueue: OperationQueue { get }
    
    var mediaDownloadInProgress: [IndexPath: Operation] { get set }
    var mediaDownloadQueue: OperationQueue { get }
}

class PendingOperations: PendingOperationsProtocol {
    lazy var profileDownloadInProgress: [IndexPath: Operation] = [:]
    lazy var profileDownloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Prfile Download Queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    lazy var mediaDownloadInProgress: [IndexPath: Operation] = [:]
    lazy var mediaDownloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Media Download Queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}
