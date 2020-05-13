//
//  ArticlesViewModelOutputMock.swift
//  Jet2TTTests
//
//  Created by Rahul Sharma on 13/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

@testable import Jet2TT
import Foundation


final class ArticlesViewModelOutputMock: ArticlesViewModelOutput {
    
    private(set) var onFetchCompletedCallCount: Int = 0
    private(set) var onFetchFailedCallCount: Int = 0
    private(set) var tableViewReloadItemsAtIndexPathCallCount: Int = 0
    
    func onFetchCompleted(with blogItems: [BlogItem]) {
        onFetchCompletedCallCount += 1
    }
    
    func onFetchFailed(with reason: String) {
        onFetchFailedCallCount += 1
    }
    
    func tableViewReloadItemsAt(_ indexPaths: [IndexPath]) {
        tableViewReloadItemsAtIndexPathCallCount += 1
    }
}
