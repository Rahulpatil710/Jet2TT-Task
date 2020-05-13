//
//  ArticlesViewModelMock.swift
//  Jet2TTTests
//
//  Created by Rahul Sharma on 13/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

@testable import Jet2TT
import Foundation

final class ArticlesViewModelMock: ArticlesViewModelInput {
    
    private(set) var onViewWillAppearCallCount: Int = 0
    private(set) var numberOfRowsCallCount: Int = 0
    private(set) var presentableBlogCallCount: Int = 0
    private(set) var presentableBlogImageCallCount: Int = 0
    private(set) var tableViewCellForProfileImageCallCount: Int = 0
    private(set) var tableViewCellForMediaImageCallCount: Int = 0
    private(set) var tableViewWillBeginDraggingCallCount: Int = 0
    private(set) var tableViewDidEndDraggingCallCount: Int = 0
    private(set) var scrollViewReachedAtMaxCallCount: Int = 0
    private(set) var loadImagesOnScreenVisibleCellsCallCount: Int = 0
    
    
    func onViewWillAppear() {
        onViewWillAppearCallCount += 1
    }
    func numberOfRows() -> Int {
        numberOfRowsCallCount += 1
        return numberOfRowsCallCount
    }
    func presentableBlog(at index: Int) -> BlogItem? {
        presentableBlogCallCount += 1
        return nil
    }
    func presentableBlogImage(at index: Int) -> BlogImage? {
        presentableBlogImageCallCount += 1
        return nil
    }
    func tableViewCellForProfileImage(at indexPath: IndexPath) {
        tableViewCellForProfileImageCallCount += 1
    }
    func tableViewCellForMediaImage(at indexPath: IndexPath) {
        tableViewCellForMediaImageCallCount += 1
    }
    func tableViewWillBeginDragging() {
        tableViewWillBeginDraggingCallCount  += 1
    }
    func tableViewDidEndDragging() {
        tableViewDidEndDraggingCallCount += 1
    }
    func scrollViewReachedAtMax() {
        scrollViewReachedAtMaxCallCount += 1
    }
    func loadImagesOnScreenVisibleCells(_ indexPaths: [IndexPath]) {
        loadImagesOnScreenVisibleCellsCallCount += 1
    }
}
