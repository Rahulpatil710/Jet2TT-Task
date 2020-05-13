//
//  ArticlesViewControllerTest.swift
//  Jet2TTTests
//
//  Created by Rahul Sharma on 13/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

import XCTest
@testable import Jet2TT

final class ArticlesViewControllerTest: XCTestCase {
    
    private var viewModel: ArticlesViewModelMock!
    private var articleViewController: ArticlesViewController!
    
    override func setUp() {
        super.setUp()
        viewModel = ArticlesViewModelMock()
        articleViewController = ArticlesViewController(viewModel)
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
        articleViewController = nil
    }
    
    func testArticlesViewController_OnViewWillAppear() {
        viewModel.onViewWillAppear()
        XCTAssertNotNil(viewModel.onViewWillAppearCallCount)
        XCTAssertEqual(viewModel.onViewWillAppearCallCount, 1)
    }
    
    func testArticlesViewController_NumberOfItemsInSection() {
        let count = viewModel.numberOfRows()
        XCTAssertNotNil(viewModel.numberOfRowsCallCount)
        XCTAssertEqual(viewModel.numberOfRowsCallCount, 1)
        XCTAssertEqual(viewModel.numberOfRowsCallCount, count)
    }
        
    func testArticlesViewController_ScrollViewWillBeginDragging() {
        viewModel.tableViewWillBeginDragging()
        XCTAssertEqual(viewModel.tableViewWillBeginDraggingCallCount, 1)
    }
    
    func testArticlesViewController_ScrollViewDidEndDragging() {
        viewModel.tableViewDidEndDragging()
        XCTAssertEqual(viewModel.tableViewDidEndDraggingCallCount, 1)
    }
    
    func testArticlesViewController_ScrollViewDidEndDecelerating() {
        viewModel.tableViewDidEndDragging()
        XCTAssertEqual(viewModel.tableViewDidEndDraggingCallCount, 1)
    }
    
    func testArticlesViewController_StartDownloadProfileImage() {
        let indexPath = IndexPath(row: 0, section: 0)
        viewModel.tableViewCellForProfileImage(at: indexPath)
        XCTAssertEqual(viewModel.tableViewCellForProfileImageCallCount, 1)
    }
    
    func testArticlesViewController_StartDownloadMediaImage() {
        let indexPath = IndexPath(row: 0, section: 0)
        viewModel.tableViewCellForMediaImage(at: indexPath)
        XCTAssertEqual(viewModel.tableViewCellForMediaImageCallCount, 1)
    }

    func testArticlesViewController_ScrollViewReachedAtMaxCallCount() {
        viewModel.scrollViewReachedAtMax()
        XCTAssertEqual(viewModel.scrollViewReachedAtMaxCallCount, 1)
    }
    
    func testArticlesViewController_LoadImagesOnScreenVisibleCellsCallCount() {
        let indexPath = IndexPath(row: 0, section: 0)
        viewModel.loadImagesOnScreenVisibleCells([indexPath])
        XCTAssertEqual(viewModel.loadImagesOnScreenVisibleCellsCallCount, 1)
    }
}
