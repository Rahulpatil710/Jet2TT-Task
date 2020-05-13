//
//  RPImageTest.swift
//  Jet2TTTests
//
//  Created by Rahul Patil on 13/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

import XCTest
@testable import Jet2TT

final class RPImageTest: XCTestCase {
    private(set) var image: RPImage!
    
    override func setUp() {
        super.setUp()
        guard let url = URL(string: "http://sandbox.bottlerocketapps.com/BR_iOS_CodingExam_2015_Server/Images/hopdoddy.png") else { return }
        image  = RPImage("1", imageUrl: url)
    }
    
    override func tearDown() {
        super.tearDown()
        image = nil
    }
    
    func testRPImage() {
        guard let url = URL(string: "http://sandbox.bottlerocketapps.com/BR_iOS_CodingExam_2015_Server/Images/hopdoddy.png") else { return }
        XCTAssertEqual(image.id, "1")
        XCTAssertEqual(image.url, url)
        XCTAssertEqual(image.state, .new)
        XCTAssertEqual(image.imageData, nil)
    }
}
