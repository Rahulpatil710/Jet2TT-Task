//
//  CoreDataManager.swift
//  Jet2TT
//
//  Created by Rahul Patil on 12/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataManagerProtocol {
    static func shared() -> CoreDataManagerProtocol
    func saveContext ()
    func saveDataInBackground()
    func prepare(_ blogs: [Blog])
    func createEntity(from blog: Blog) -> BlogItem?
    func fetchBlogItems() -> [BlogItem]
    func updateBlogItem(for id: String, as imageData: Data, of type: ImageType)
}


class CoreDataManager: NSObject, CoreDataManagerProtocol {

    private override init() {
        super.init()
    }
    // Create a shared Instance
    static private let instance = CoreDataManager()
    
    // Shared Function
    static func shared() -> CoreDataManagerProtocol {
        return instance
    }
    
    // Get the location where the core data DB is stored
    private lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(urls[urls.count-1])
        return urls[urls.count-1]
    }()
    
    private func applicationLibraryDirectory() {
        print(applicationDocumentsDirectory)
        if let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {
            print(url.absoluteString)
        }
    }
    
    // MARK: - Core Data stack
    
    // Get the managed Object Context
    lazy private var managedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    lazy private var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Jet2TT")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // Save Data in background
    func saveDataInBackground() {
        persistentContainer.performBackgroundTask { (context) in
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
    
    func prepare(_ blogs: [Blog]) {
        // loop through all the data received from the Web and then convert to managed object and save them
        _ = blogs.map {
            self.createEntity(from: $0)
        }
        saveContext()
    }
        
    func createEntity(from blog: Blog) -> BlogItem? {
        let blogItem = BlogItem(context: managedObjectContext)
        
        blogItem.id = blog.id
        blogItem.profileUrl = blog.user.first?.avatar
        
        blogItem.userName = (blog.user.first?.name ?? "").count == 0 ? (blog.user.first?.lastname ?? "") : (blog.user.first?.name ?? "") + " " + (blog.user.first?.lastname ?? "")
        blogItem.designation = blog.user.first?.designation
        
        blogItem.time = blog.createdAt
        
        blogItem.isMediaPresent = (blog.media.first?.title ?? "").count > 0 ? true : false
        blogItem.mediaUrl = blog.media.first?.image
        
        blogItem.content = blog.content
        blogItem.title = blog.media.first?.title
        blogItem.url = blog.media.first?.url
        
        blogItem.likes = Int64(blog.likes)
        blogItem.comments = Int64(blog.comments)
        return blogItem
    }
    
    func fetchBlogItems() -> [BlogItem] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "BlogItem")
        request.returnsObjectsAsFaults = false
        do {
            if let blogItems = try managedObjectContext.fetch(request) as? [BlogItem] {
                return blogItems
            }
        } catch let error {
            print("Got an error and description \(error.localizedDescription)")
        }
        return [BlogItem]()
    }
    
    func updateBlogItem(for id: String, as imageData: Data, of type: ImageType) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "BlogItem")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "id == %@", id)
        do {
            if let blogItem = try managedObjectContext.fetch(request).first as? BlogItem {
                switch type {
                case .profile: blogItem.profileImage = imageData
                case .media: blogItem.mediaImage = imageData
                }
                saveDataInBackground()
            }
        } catch let error {
            print("Got an error and description \(error.localizedDescription)")
        }
    }
}
