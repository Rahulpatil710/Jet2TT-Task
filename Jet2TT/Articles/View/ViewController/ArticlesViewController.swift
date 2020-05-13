//
//  ArticlesViewController.swift
//  Jet2TT
//
//  Created by Rahul Patil on 11/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

import UIKit

enum ImageType {
    case profile
    case media
}

class ArticlesViewController: UIViewController {
    
    private let viewModel:ArticlesViewModelInput!
    private var dataSource: UITableViewDiffableDataSource<Section, BlogItem>!
    
    init(_ viewModel: ArticlesViewModelInput) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var tableView: UITableView! = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        return tableView
    }()
    
    private lazy var indicatorView: UIActivityIndicatorView! = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indicatorView)
        
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            tableView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
        return indicatorView
    }()
    
    
    var profileImageSize: CGSize?
    var mediaImageSize: CGSize?
    
    var tableViewScrolling = false
    
    private let cache = ImageCache.shared
    private let serialQueue = DispatchQueue(label: "Decode Queue")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpNavigationTitle()
        setUpTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.onViewWillAppear()
        configureDateSource()
    }
    
    private func setUpNavigationTitle() {
        navigationItem.title = "Articles"
    }
    
    private func registerCell(_ cellName: String) {
        let nibName = UINib(nibName: cellName, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: cellName)
    }
    
    private func setUpTableView() {
        registerCell(String(describing: BlogTableViewCell.self))
        tableView.isHidden = true
        
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        indicatorView.startAnimating()
    }
    
    private func configureDateSource() {
        dataSource = UITableViewDiffableDataSource<Section, BlogItem>(tableView: tableView, cellProvider: { (tableView, indexPath, blog) -> UITableViewCell? in
            guard let blog = self.viewModel.presentableBlog(at: indexPath.row),
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BlogTableViewCell.self), for: indexPath) as? BlogTableViewCell else { return UITableViewCell() }
            cell.layoutIfNeeded()
            cell.updateCell(blog)
            
            if let blogImage = self.viewModel.presentableBlogImage(at: indexPath.row) {
                self.addImage(to: cell.profileImageView,
                              with: cell.profileActivityIndicator,
                              and: blogImage.profileImage,
                              at: indexPath,
                              of: .profile,
                              update: &blog.profileImage)
                self.addImage(to: cell.mediaImageView,
                              with: cell.mediaActivityIndicator,
                              and: blogImage.mediaImage,
                              at: indexPath,
                              of: .media,
                              update: &blog.mediaImage)
                self.profileImageSize = cell.profileImageView.bounds.size
                self.mediaImageSize = cell.mediaImageView.bounds.size
            }
            cell.layoutIfNeeded()
            return cell
        })
    }
    
    private func createSnapShot(from blogIems: [BlogItem]) {
        DispatchQueue.main.async {
            var snapshot = NSDiffableDataSourceSnapshot<Section, BlogItem>()
            snapshot.appendSections([.main])
            snapshot.appendItems(blogIems)
            self.dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
        }
    }
    
    private func addImage(to imageView: UIImageView,
                          with activityIndicator: UIActivityIndicatorView,
                          and blogImage: RPImage?,
                          at indexPath: IndexPath,
                          of type: ImageType,
                          update imageData: inout Data?) {
        if let image = blogImage {
            switch image.state {
            case .new:
                activityIndicator.startAnimating()
                imageView.image = nil
                
                let isReachable = Reachability.shared.isConnectedToNetwork()
                guard isReachable == true else {
                    activityIndicator.stopAnimating()
                    switch type {
                    case .profile: imageView.image = UIImage(systemName: "person.circle.fill")
                    case .media: imageView.image = UIImage(systemName: "film")
                    }
                    let action = UIAlertAction(title: "Ok", style: .default)
                    displayAlert(with: "Warning" , message: "No internet connection", actions: [action])
                    return
                }
                
                // If collectionView is not scrolling then start download image
                if !tableView.isDragging && !tableView.isDecelerating {
                    switch type {
                    case .profile: self.viewModel.tableViewCellForProfileImage(at: indexPath)
                    case .media: self.viewModel.tableViewCellForMediaImage(at: indexPath)
                    }
                }
            case .downloaded:
                activityIndicator.stopAnimating()
                // Checking for cached image
                if let cachedImage = self.cache.image(for: image.url) {
                    imageView.image = cachedImage
                } else if let data = image.imageData {
                    if imageData == nil {
                        imageData = data
                        let coreDataManager = CoreDataManager.shared()
                        coreDataManager.updateBlogItem(for: image.id, as: data, of: type)
                    }
                    
                    let imageSize = imageView.bounds.size
                    let scale = tableView.traitCollection.displayScale
                    
                    // Creating downsample image for reducing memory
                    // This reduced image size near by 50%
                    let downsampledImage = UIImage.downsample(imageAt: data, to: imageSize, scale: scale)
                    imageView.image = downsampledImage
                    
                    // Storing downsampled image in cache with respect to url
                    self.cache.insertImage(downsampledImage, for: image.url)
                }
                
            case .failed:
                activityIndicator.stopAnimating()
                switch type {
                case .profile: imageView.image = UIImage(systemName: "person.circle.fill")
                case .media: imageView.image = UIImage(systemName: "film")
                }
            }
        }
    }
    
    private func prefetchImage(to blogImage: RPImage?,
                               with imageSize: CGSize?,
                               at indexPath: IndexPath,
                               of type: ImageType) {
        if let image = blogImage {
            switch image.state {
            case .new:
                serialQueue.async {
                    switch type {
                    case .profile: self.viewModel.tableViewCellForProfileImage(at: indexPath)
                    case .media: self.viewModel.tableViewCellForMediaImage(at: indexPath)
                    }
                }
                
            case .downloaded:
                if let _ = cache.image(for: image.url) {
                    break
                } else if let data = image.imageData {
                    serialQueue.async {
                        // Creating downsample image for reducing memory
                        guard let imageSize = imageSize else { return }
                        let scale = self.tableView.traitCollection.displayScale
                        let downsampledImage = UIImage.downsample(imageAt: data, to: imageSize, scale: scale)
                        
                        // Storing downsampled image in cache with respect to url
                        self.cache.insertImage(downsampledImage, for: image.url)
                    }
                }
                
            case .failed: break
            }
        }
    }
    
    private func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
}

extension ArticlesViewController {
    fileprivate enum Section {
        case main
    }
}

extension ArticlesViewController: ArticlesViewModelOutput, AlertDisplayer {
    
    func onFetchCompleted(with blogItems: [BlogItem]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.tableView.isHidden {
                self.indicatorView.stopAnimating()
                self.tableView.isHidden = false
            }
            self.createSnapShot(from: blogItems)
        }
    }
    
    func onFetchFailed(with reason: String) {
        indicatorView.stopAnimating()
        let action = UIAlertAction(title: "Ok", style: .default)
        displayAlert(with: "Warning" , message: reason, actions: [action])
    }
    
    func tableViewReloadItemsAt(_ indexPaths: [IndexPath]) {
        DispatchQueue.main.async {
            let indexPathToReload = self.visibleIndexPathsToReload(intersecting: indexPaths)
            for indexPath in indexPathToReload {
                if let blogItem = self.viewModel.presentableBlog(at: indexPath.row) {
                    var currentSnapshot = self.dataSource.snapshot()
                    currentSnapshot.reloadItems([blogItem])
                    self.dataSource.apply(currentSnapshot, animatingDifferences: true)
                }
            }
        }
    }
}

extension ArticlesViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if !self.tableViewScrolling {
            for indexPath in indexPaths {
                if indexPath.row == viewModel.numberOfRows() - 1 {
                    return
                }
                guard let blogImage = self.viewModel.presentableBlogImage(at: indexPath.row) else { return }
                self.prefetchImage(to: blogImage.profileImage,
                                   with: self.profileImageSize,
                                   at: indexPath,
                                   of: .profile)
                self.prefetchImage(to: blogImage.mediaImage,
                                   with: self.mediaImageSize,
                                   at: indexPath,
                                   of: .media)
            }
        }
    }
}

extension ArticlesViewController:UITableViewDelegate, UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        tableViewScrolling = true
        viewModel.tableViewWillBeginDragging()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            tableViewScrolling = false
            viewModel.tableViewDidEndDragging()
            if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows {
                viewModel.loadImagesOnScreenVisibleCells(indexPathsForVisibleRows)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        tableViewScrolling = false
        viewModel.tableViewDidEndDragging()
        if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows {
            viewModel.loadImagesOnScreenVisibleCells(indexPathsForVisibleRows)
        }
        let currentOffset: CGFloat = scrollView.contentOffset.y
        let contentHeight: CGFloat = scrollView.contentSize.height
        let scrollHeight: CGFloat = scrollView.frame.size.height
        if currentOffset + (3/2*scrollHeight)  >= contentHeight {
            viewModel.onWillDisplayAtLastCell()
        }
    }
}
