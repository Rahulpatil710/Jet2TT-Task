//
//  ArticlesViewController.swift
//  Jet2TT
//
//  Created by Rahul Patil on 11/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

import UIKit

class ArticlesViewController: UIViewController {

    private let viewModel:ArticlesViewModelInput!
    
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
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
       return tableView
    }()
    
    var imageSize: CGSize?
    var scale: CGFloat?
    var tableViewScrolling = false
    private let cache = ImageCache.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationTitle()
        setUpTableView()
    }
    
    private func setUpNavigationTitle() {
        navigationItem.title = "Articles"
    }
    
    private func setUpTableView() {
        registerCell()
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        viewModel.onViewDidLoad()
    }
    
    private func registerCell() {
        let cellName = String(describing: BlogTableViewCell.self)
        let nibName = UINib(nibName: cellName, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: cellName)
    }
}

extension ArticlesViewController: ArticlesViewModelOutput {
    func showArticles() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
        
    func tableViewReloadItemsAt(_ indexPaths: [IndexPath]) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: indexPaths, with: .automatic)
            self.tableView.endUpdates()
        }
    }
}

extension ArticlesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let blog = viewModel.presentableBlog(at: indexPath.row),
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BlogTableViewCell.self), for: indexPath) as? BlogTableViewCell else { return UITableViewCell() }
        cell.layoutIfNeeded()
        cell.updateCell(blog)
        if let blogImage = viewModel.presentableBlogImage(at: indexPath.row) {
            let profileImage = blogImage.profileImage
            switch profileImage.state {
            case .new:
                cell.profileActivityIndicator.startAnimating()
                cell.profileImageView.image = nil
                // If collectionView is not scrolling then start download image
                if !tableView.isDragging && !tableView.isDecelerating {
                    viewModel.tableViewCellForProfileImage(at: indexPath)
                }
            case .downloaded:
                cell.profileActivityIndicator.stopAnimating()
                // Checking for cached image
                if let cachedImage = cache.image(for: profileImage.url) {
                    cell.profileImageView.image = cachedImage
                } else if let data = profileImage.imageData {
                    imageSize = cell.profileImageView.bounds.size
                    scale = tableView.traitCollection.displayScale
                    
                    // Creating downsample image for reducing memory
                    // This reduced image size near by 50%
                    let downsampledImage = UIImage.downsample(imageAt: data, to: imageSize!, scale: scale!)
                    cell.profileImageView.image = downsampledImage
                    
                    // Storing downsampled image in cache with respect to url
                    cache.insertImage(downsampledImage, for: profileImage.url)
                }
                
            case .failed:  cell.profileActivityIndicator.stopAnimating()
            }
            
            if let mediaImage = blogImage.mediaImage {
                switch mediaImage.state {
                case .new:
                    cell.mediaActivityIndicator.startAnimating()
                    cell.mediaImageView.image = nil
                    // If collectionView is not scrolling then start download image
                    if !tableView.isDragging && !tableView.isDecelerating {
                        viewModel.tableViewCellForMediaImage(at: indexPath)
                    }
                case .downloaded:
                    cell.profileActivityIndicator.stopAnimating()
                    // Checking for cached image
                    if let cachedImage = cache.image(for: mediaImage.url) {
                        cell.mediaImageView.image = cachedImage
                    } else if let data = mediaImage.imageData {
                        imageSize = cell.profileImageView.bounds.size
                        scale = tableView.traitCollection.displayScale
                        
                        // Creating downsample image for reducing memory
                        // This reduced image size near by 50%
                        let downsampledImage = UIImage.downsample(imageAt: data, to: imageSize!, scale: scale!)
                        cell.mediaImageView.image = downsampledImage
                        
                        // Storing downsampled image in cache with respect to url
                        cache.insertImage(downsampledImage, for: mediaImage.url)
                    }
                    
                case .failed:  cell.mediaActivityIndicator.stopAnimating()
                }
            }
        }
        cell.layoutIfNeeded()
        return cell
    }
}

extension ArticlesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if viewModel.numberOfRows() - 1 == indexPath.row {
            viewModel.onWillDisplayAtLastCell()
        }
    }
}

extension ArticlesViewController: UIScrollViewDelegate {
    
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
    }
}
