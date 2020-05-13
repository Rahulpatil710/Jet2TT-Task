//
//  ArticlesViewModelTest.swift
//  Jet2TTTests
//
//  Created by Rahul Sharma on 13/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

import XCTest
@testable import Jet2TT

final class ArticlesViewModelTest: XCTestCase {
    
    private var network: BlogsAPIMock!
    private var coreDataManager: CoreDataManagerMock!
    private var pendingOperations: PendingOperationsMock!
    private var output: ArticlesViewModelOutputMock!
    private var viewModel: ArticlesViewModel!

    override func setUp() {
        super.setUp()
        network = BlogsAPIMock()
        pendingOperations = PendingOperationsMock()
        coreDataManager = CoreDataManagerMock()
        viewModel = ArticlesViewModel(network, and: pendingOperations, with: coreDataManager)
        output = ArticlesViewModelOutputMock()
        viewModel.output = output
    }
    
    override func tearDown() {
        super.tearDown()
        network = nil
        output = nil
        viewModel = nil
        pendingOperations = nil
    }
    
    func testArticlesViewModel_FetchBlogs_Success() {
        network.apiSuccessful = true
        viewModel.onViewWillAppear()
        XCTAssertEqual(network.fetchBlogsCallCount, 1)
        XCTAssertEqual(network.blogsCount, 2)
    }
    
    func testArticlesViewModel_FetchBlogs_Fail() {
        network.apiSuccessful = false
        viewModel.onViewWillAppear()
        XCTAssertEqual(network.fetchBlogsCallCount, 1)
        XCTAssertEqual(network.blogsCount, 0)
    }
    
    func testArticlesViewModel_PendingOperations_ProfileDownloadInProgress() {
        pendingOperations.profileDownloadInProgress = [:]
        XCTAssertEqual(pendingOperations.profileDownloadInProgressCallCount, 1)
    }
    
    func testArticlesViewModel_PendingOperations_ProfileDownloadIQueue() {
        let downloadQueue = pendingOperations.profileDownloadQueue
        XCTAssertNotNil(downloadQueue)
        XCTAssertEqual(pendingOperations.profileDownloadQueueCallCount, 1)
    }
    
    func testArticlesViewModel_PendingOperations_MediaDownloadInProgress() {
        pendingOperations.mediaDownloadInProgress = [:]
        XCTAssertEqual(pendingOperations.mediaDownloadInProgressCallCount, 1)
    }
    
    func testArticlesViewModel_PendingOperations_MediaDownloadQueue() {
        let downloadQueue = pendingOperations.mediaDownloadQueue
        XCTAssertNotNil(downloadQueue)
        XCTAssertEqual(pendingOperations.mediaDownloadQueueCallCount, 1)
    }
}
