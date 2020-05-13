//
//  ArticlesViewControllerUITest.swift
//  Jet2TTUITests
//
//  Created by Rahul Sharma on 13/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

import XCTest
@testable import Jet2TT

final class ArticlesViewControllerUITest: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testArticlesViewControllerUI() {
        let app = XCUIApplication()
        app.launch()
        
        XCUIApplication().tables/*@START_MENU_TOKEN@*/.staticTexts["Tyler Hauck"]/*[[".cells.staticTexts[\"Tyler Hauck\"]",".staticTexts[\"Tyler Hauck\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let tablesQuery = XCUIApplication().tables
        XCTAssertNotNil(tablesQuery)
        
        let label = tablesQuery.staticTexts["Ryann Rohan"]
        XCTAssertNotNil(label)
        label.swipeUp()
        
        let label2 = tablesQuery.staticTexts["Dynamic Data Assistant"]
        XCTAssertNotNil(label2)
    }
}
