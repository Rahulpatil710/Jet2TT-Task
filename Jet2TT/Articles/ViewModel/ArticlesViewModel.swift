//
//  ArticlesViewModel.swift
//  Jet2TT
//
//  Created by Rahul Patil on 11/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

import Foundation

protocol ArticlesViewModelInput {
    func onViewDidLoad()
    
    func numberOfRows() -> Int
    func presentableBlog(at index: Int) -> Blog?
    func presentableBlogImage(at index: Int) -> BlogImage?
    
    func tableViewCellForProfileImage(at indexPath: IndexPath)
    func tableViewCellForMediaImage(at indexPath: IndexPath)

    func tableViewWillBeginDragging()
    func tableViewDidEndDragging()
    
    func onWillDisplayAtLastCell()
    
    func loadImagesOnScreenVisibleCells(_ indexPaths: [IndexPath])
}

protocol ArticlesViewModelOutput: class {
    func showArticles()
    
    func tableViewReloadItemsAt(_ indexPaths: [IndexPath])
}

class ArticlesViewModel: ArticlesViewModelInput {
    private let blogsAPI: BlogsNetworkProtocol!
    private var pendingOperations: PendingOperationsProtocol!

    weak var output:ArticlesViewModelOutput?
    fileprivate var blogs = Blogs()
    fileprivate var blogImages = [BlogImage]()
    fileprivate var page: Int = 1
    fileprivate var reachedMaxLimit: Bool = false

    init(_ blogsAPI: BlogsNetworkProtocol, and pendingOperations: PendingOperationsProtocol ) {
        self.blogsAPI = blogsAPI
        self.pendingOperations = pendingOperations
    }
    
    private func fetchBlogs() {
        if reachedMaxLimit {
            return
        }
        blogsAPI.fetchBlogs(page) { (blogs, responseType, message) in
            if responseType == .success {
                if let newBlogs = blogs {
                    self.updateBlogs(newBlogs)
                    self.page += 1
                    self.output?.showArticles()
                } else {
                    self.reachedMaxLimit = true
                }
            }
        }
    }
    
    private func updateBlogs(_ newBlogs: Blogs) {
        updateBlogImages(newBlogs)
        if blogs.count > 0 {
            blogs += newBlogs
        } else {
            blogs = newBlogs
        }
    }
    
    private func updateBlogImages(_ newBlogs: Blogs) {
        var newBlogImages = [BlogImage]()
        for newBlog in newBlogs {
            if let profile = newBlog.user.first?.avatar {
                let profileImage = RPImage(profile)
                if let media = newBlog.media.first?.image {
                    let mediaImage = RPImage(media)
                    newBlogImages.append(BlogImage(profileImage, and: mediaImage))
                } else {
                    newBlogImages.append(BlogImage(profileImage))
                }
            }
        }
        if blogImages.count > 0 {
            blogImages += newBlogImages
        } else {
            blogImages = newBlogImages
        }
    }
    
    func onViewDidLoad() {
        fetchBlogs()
    }
    
    func numberOfRows() -> Int {
        return blogs.count
    }
    
    func presentableBlog(at index: Int) -> Blog? {
        guard index < blogs.count else { return nil }
        return blogs[index]
    }
    
    func presentableBlogImage(at index: Int) -> BlogImage? {
        guard index < blogImages.count else { return nil }
        return blogImages[index]
    }
    
    func tableViewCellForProfileImage(at indexPath: IndexPath) {
        if let image = presentableBlogImage(at: indexPath.row) {
            startDownload(profile: image.profileImage, at: indexPath)
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
    
    func onWillDisplayAtLastCell() {
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
                    if recordToProcess.profileImage.state == .new {
                        startDownload(profile: recordToProcess.profileImage, at: indexPath)
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
