//
//  PendingOperationsMock.swift
//  Jet2TTTests
//
//  Created by Rahul Sharma on 13/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

@testable import Jet2TT
import Foundation

final class PendingOperationsMock: PendingOperationsProtocol {
    
     private(set) var profileDownloadInProgressCallCount: Int = 0
     private(set) var profileDownloadQueueCallCount: Int = 0
     private(set) var mediaDownloadInProgressCallCount: Int = 0
     private(set) var mediaDownloadQueueCallCount: Int = 0
    
    var profileDownloadInProgress: [IndexPath : Operation] = [:] {
        didSet {
            profileDownloadInProgressCallCount += 1
        }
    }
    
    var profileDownloadQueue: OperationQueue {
        profileDownloadQueueCallCount += 1
        return OperationQueue()
    }
    
    var mediaDownloadInProgress: [IndexPath : Operation] = [:] {
        didSet {
            mediaDownloadInProgressCallCount += 1
        }
    }
    
    var mediaDownloadQueue: OperationQueue {
        mediaDownloadQueueCallCount += 1
        return OperationQueue()
    }
}
