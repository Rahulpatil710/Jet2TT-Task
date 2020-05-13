//
//  ArticlesViewModel.swift
//  Jet2TT
//
//  Created by Rahul Patil on 11/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

import Foundation

protocol ArticlesViewModelInput {
    func onViewWillAppear()
    
    func numberOfRows() -> Int
    func presentableBlog(at index: Int) -> BlogItem?
    func presentableBlogImage(at index: Int) -> BlogImage?
    
    func tableViewCellForProfileImage(at indexPath: IndexPath)
    func tableViewCellForMediaImage(at indexPath: IndexPath)
    
    func tableViewWillBeginDragging()
    func tableViewDidEndDragging()
    
    func scrollViewReachedAtMax()
    
    func loadImagesOnScreenVisibleCells(_ indexPaths: [IndexPath])
}

protocol ArticlesViewModelOutput: class {
    func onFetchCompleted(with blogItems: [BlogItem])
    func onFetchFailed(with reason: String)
    
    func tableViewReloadItemsAt(_ indexPaths: [IndexPath])
}

class ArticlesViewModel: ArticlesViewModelInput {
    
    private let blogsAPI: BlogsNetworkProtocol!
    private var pendingOperations: PendingOperationsProtocol!
    private var coreDataManager: CoreDataManagerProtocol!
    weak var output:ArticlesViewModelOutput?
    
    fileprivate var blogItems = [BlogItem]()
    fileprivate var blogImages = [BlogImage]()
    
    private var currentPage = 1
    fileprivate var reachedMaxLimit: Bool = false
    private var isFetchInProgress = false
    
    init(_ blogsAPI: BlogsNetworkProtocol, and pendingOperations: PendingOperationsProtocol, with coreDataManager: CoreDataManagerProtocol) {
        self.blogsAPI = blogsAPI
        self.pendingOperations = pendingOperations
        self.coreDataManager = coreDataManager
    }
    
    private func fetchBlogs() {
        if reachedMaxLimit {
            return
        }
        guard !isFetchInProgress else {
            return
        }
        isFetchInProgress = true

        
        let blogItems = coreDataManager.fetchBlogItems()
        if blogItems.count > 0, self.currentPage < blogItems.count/10 + 1 {
            self.currentPage = blogItems.count/10 + 1
            self.updateBlogImages(blogItems)
            self.blogItems  = blogItems
            self.isFetchInProgress = false
            self.output?.onFetchCompleted(with: blogItems)
            return
        }
        blogsAPI.fetchBlogs(currentPage) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isFetchInProgress = false
                    self.output?.onFetchFailed(with: error.reason)
                }
                
            case .success(let newBlogs):
                DispatchQueue.main.async {
                    self.currentPage += 1
                    self.isFetchInProgress = false
                    self.reachedMaxLimit = newBlogs.count == 0 ? true : false
                                    
                    let coreDataManager = CoreDataManager.shared()
                    coreDataManager.prepare(newBlogs)
                    
                    let blogItems = coreDataManager.fetchBlogItems()
                    
                    self.updateBlogImages(blogItems)
                    self.blogItems = blogItems
                        
                    self.output?.onFetchCompleted(with: blogItems)
                }
            }
        }
    }
    
    private func updateBlogImages(_ newBlogs: [BlogItem]) {
        blogImages = [BlogImage]()
        for newBlog in newBlogs {
            let profileImage = getImage(from: newBlog, for: .profile)
            let mediaImage = getImage(from: newBlog, for: .media)
            blogImages.append(BlogImage(profileImage, and: mediaImage))
        }
    }
    
    private func getImage(from blogItem: BlogItem, for type: ImageType) -> RPImage? {
        var url: URL?
        var imageData: Data?
        switch type {
        case .profile:
            url = blogItem.profileUrl
            imageData = blogItem.profileImage
            
        case .media:
            url = blogItem.mediaUrl
            imageData = blogItem.mediaImage
        }
        
        if let id = blogItem.id, let url = url {
            let image = RPImage(id, imageUrl: url)
            if let imageData = imageData {
                image.state = .downloaded
                image.imageData = imageData
            }
            return image
        }
        return nil
    }
    
    func onViewWillAppear() {
        fetchBlogs()
    }
    
    func numberOfRows() -> Int {
        return blogItems.count
    }
    
    func presentableBlog(at index: Int) -> BlogItem? {
        guard index < blogItems.count else { return nil }
        return blogItems[index]
    }
    
    func presentableBlogImage(at index: Int) -> BlogImage? {
        guard index < blogImages.count else { return nil }
        return blogImages[index]
    }
    
    func tableViewCellForProfileImage(at indexPath: IndexPath) {
        if let image = presentableBlogImage(at: indexPath.row),
            let profileImage = image.profileImage {
            startDownload(profile: profileImage, at: indexPath)
        }
    }
    
    func tableViewCellForMediaImage(at indexPath: IndexPath) {
        if let image = presentableBlogImage(at: indexPath.row),
            let mediaImage = image.mediaImage {
            startDownload(media: mediaImage, at: indexPath)
        }
    }
    
    func tableViewWillBeginDragging() {
        suspendAllOpertions()
    }
    
    func tableViewDidEndDragging() {
        resumeAllOperations()
    }
    
    func scrollViewReachedAtMax() {
        fetchBlogs()
    }
    
    // Load images after scrolling stops or viewWillAppear called on visible cells
    // If images not downloaded yet then start them to download
    // Other all pending operation who are cancelled remove from pending operation dicationary
    func loadImagesOnScreenVisibleCells(_ indexPaths: [IndexPath]) {
        if indexPaths.count > 0 {
            var allPendingOperations = Set(pendingOperations.profileDownloadInProgress.keys)
            allPendingOperations.formUnion(pendingOperations.mediaDownloadInProgress.keys)
            
            let visibleIndexPath = Set(indexPaths)
            
            var toBecancelled = allPendingOperations
            toBecancelled.subtract(visibleIndexPath)
            
            var toBeStarted = visibleIndexPath
            toBeStarted.subtract(allPendingOperations)
            
            for indexPath in toBecancelled {
                if let pendingDownload = pendingOperations.profileDownloadInProgress[indexPath] {
                    pendingDownload.cancel()
                }
                pendingOperations.profileDownloadInProgress.removeValue(forKey: indexPath)
                
                if let pendingDownload = pendingOperations.mediaDownloadInProgress[indexPath] {
                    pendingDownload.cancel()
                }
                pendingOperations.mediaDownloadInProgress.removeValue(forKey: indexPath)
            }
            for indexPath in toBeStarted {
                if let recordToProcess = presentableBlogImage(at: indexPath.item) {
                    if let profileImage = recordToProcess.profileImage,
                        profileImage.state == .new {
                        startDownload(profile: profileImage, at: indexPath)
                    }
                    if let mediaImage = recordToProcess.mediaImage,
                        mediaImage.state == .new {
                        startDownload(media: mediaImage, at: indexPath)
                    }
                }
            }
        }
    }
}

extension ArticlesViewModel {
    // Add image downloader operation in pending operation queue
    // Once image download complete remove it from operation  dictionary
    // Reload particular collectionview cell
    private func startDownload(profile image: RPImage, at indexPath: IndexPath) {
        guard pendingOperations.profileDownloadInProgress[indexPath] == nil else { return }
        let downloader = ImageDownloader(image)
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            self.pendingOperations.profileDownloadInProgress.removeValue(forKey: indexPath)
            self.output?.tableViewReloadItemsAt([indexPath])
        }
        pendingOperations.profileDownloadInProgress[indexPath] = downloader
        pendingOperations.profileDownloadQueue.addOperation(downloader)
    }
    
    private func startDownload(media image: RPImage, at indexPath: IndexPath) {
        guard pendingOperations.mediaDownloadInProgress[indexPath] == nil else { return }
        let downloader = ImageDownloader(image)
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            self.pendingOperations.mediaDownloadInProgress.removeValue(forKey: indexPath)
            self.output?.tableViewReloadItemsAt([indexPath])
        }
        pendingOperations.mediaDownloadInProgress[indexPath] = downloader
        pendingOperations.mediaDownloadQueue.addOperation(downloader)
    }
    
    // While scrolling or viewWillDisapper supspend all image download operations
    private func suspendAllOpertions() {
        pendingOperations.profileDownloadQueue.isSuspended = true
        pendingOperations.mediaDownloadQueue.isSuspended = true
    }
    
    // Whiwhen scrolling stops or ViewWillAppear called all supspended operations make it resume and then can start download images
    private func resumeAllOperations() {
        pendingOperations.profileDownloadQueue.isSuspended = false
        pendingOperations.mediaDownloadQueue.isSuspended = false
    }
}
