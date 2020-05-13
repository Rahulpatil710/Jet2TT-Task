//
//  BlogsAPIMock.swift
//  Jet2TTTests
//
//  Created by Rahul Sharma on 13/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

@testable import Jet2TT
import Foundation

final class BlogsAPIMock: BlogsNetworkProtocol {
    
    var apiSuccessful: Bool? = nil
    private(set) var fetchBlogsCallCount: Int = 0
    private(set) var blogsCount: Int = 0
    private(set) var blogsRawData: [[String:Any]] = [
        ["id":"1","createdAt":"2020-04-17T12:13:44.575Z","content":"calculating the program won't do anything, we need to navigate the multi-byte SMS alarm!","comments":8237,"likes":62648,"media":[["id":"1","blogId":"1","createdAt":"2020-04-16T22:43:18.606Z","image":"https://s3.amazonaws.com/uifaces/faces/twitter/joe_black/128.jpg","title":"maximized system","url":"http://providenci.com"]],"user":[["id":"1","blogId":"1","createdAt":"2020-04-16T20:17:42.437Z","name":"Dayton","avatar":"https://s3.amazonaws.com/uifaces/faces/twitter/erwanhesry/128.jpg","lastname":"Haag","city":"West Ima","designation":"Human Group Assistant","about":"Try to calculate the SDD bandwidth, maybe it will override the auxiliary card!"]]],
        ["id":"2","createdAt":"2020-04-16T18:07:46.928Z","content":"We need to bypass the open-source AI microchip!","comments":86439,"likes":71738,"media":[["id":"2","blogId":"2","createdAt":"2020-04-16T18:12:45.680Z","image":"https://s3.amazonaws.com/uifaces/faces/twitter/raquelwilson/128.jpg","title":"UIC-Franc","url":"https://alexandro.name"]],"user":[["id":"2","blogId":"2","createdAt":"2020-04-17T00:49:17.794Z","name":"Marta","avatar":"https://s3.amazonaws.com/uifaces/faces/twitter/ashernatali/128.jpg","lastname":"Ferry","city":"West Westonview","designation":"Central Intranet Developer","about":"You can't input the application without generating the bluetooth XSS application!"]]]
    ]

    private func convertArrayToJsonData(_ array: [[String:Any]]) -> Data? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: array, options: []) else { return nil }
        return jsonData
    }
    
    func fetchBlogs(_ page: Int, completion: @escaping (Result<Blogs, DataResponseError>) -> Void) {
        fetchBlogsCallCount += 1
        if apiSuccessful == true {
            if let jsonData = convertArrayToJsonData(blogsRawData) {
                do {
                    let decoder = JSONDecoder()
                    let blogs = try decoder.decode(Blogs.self, from: jsonData)
                    blogsCount = blogs.count
                    completion(.success(blogs))
                } catch {
                    completion(.failure(.decoding))
                }
            } else {
                completion(.success([Blog]()))
            }
        } else {
            completion(.failure(.error))
        }
    }
}
