//
//  CoreDataManagerMock.swift
//  Jet2TTTests
//
//  Created by Rahul Sharma on 13/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

@testable import Jet2TT
import Foundation

final class CoreDataManagerMock: CoreDataManagerProtocol {
    private(set) var sharedCallCount: Int = 0
    private(set) var saveContextCallCount: Int = 0
    private(set) var saveDataInBackgroundCallCount: Int = 0
    private(set) var prepareBlogsCallCount: Int = 0
    private(set) var createEntityFromBlogCallCount: Int = 0
    private(set) var fetchBlogItemsCallCount: Int = 0
    private(set) var updateBlogItemCallCount: Int = 0

    static func shared() -> CoreDataManagerProtocol {
        return CoreDataManagerMock()
    }
    func saveContext () {
        saveContextCallCount += 1
    }
    func saveDataInBackground() {
        saveDataInBackgroundCallCount += 1
    }
    func prepare(_ blogs: [Blog]) {
        prepareBlogsCallCount += 1
    }
    func createEntity(from blog: Blog) -> BlogItem? {
        createEntityFromBlogCallCount += 1
        return nil
    }
    func fetchBlogItems() -> [BlogItem] {
        fetchBlogItemsCallCount += 1
        return [BlogItem]()
    }
    func updateBlogItem(for id: String, as imageData: Data, of type: ImageType) {
        updateBlogItemCallCount += 1
    }
}
