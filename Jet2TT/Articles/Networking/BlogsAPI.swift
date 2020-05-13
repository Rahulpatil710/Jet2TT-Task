//
//  BlogsAPI.swift
//  Jet2TT
//
//  Created by Rahul Patil on 11/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

import Foundation

protocol BlogsNetworkProtocol {
    func fetchBlogs(_ page: Int, completion: @escaping(Result<Blogs, DataResponseError>) -> Void)
}

class BlogsAPI: BlogsNetworkProtocol {
    
    func fetchBlogs(_ page: Int, completion: @escaping(Result<Blogs, DataResponseError>) -> Void) {
        let isReachable = Reachability.shared.isConnectedToNetwork()
        guard isReachable == true else {
            completion(.failure(.noConnection))
            return
        }
        let strUrl = "https://5e99a9b1bc561b0016af3540.mockapi.io/jet2/api/v1/blogs?page=\(page)&limit=10"
        guard let url = URL(string: strUrl) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let jsonData = data else {
                completion(.failure(.network))
                return
            }
            do {
                let blogs = try JSONDecoder().decode(Blogs.self, from: jsonData)
                completion(.success(blogs))
            } catch {
                completion(.failure(.decoding))
            }
        }
        task.resume()
    }
}
