//
//  BlogItem+CoreDataProperties.swift
//  Jet2TT
//
//  Created by Rahul Patil on 13/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//
//

import Foundation
import CoreData


extension BlogItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BlogItem> {
        return NSFetchRequest<BlogItem>(entityName: "BlogItem")
    }

    @NSManaged public var id: String?
    
    @NSManaged public var profileUrl: URL?
    @NSManaged public var profileImage: Data?

    @NSManaged public var userName: String?
    @NSManaged public var designation: String?
    
    @NSManaged public var time: String?
    
    @NSManaged public var isMediaPresent: Bool
    @NSManaged public var mediaUrl: URL?
    @NSManaged public var mediaImage: Data?

    @NSManaged public var content: String?
    @NSManaged public var title: String?
    @NSManaged public var url: String?

    @NSManaged public var likes: Int64
    @NSManaged public var comments: Int64
}
