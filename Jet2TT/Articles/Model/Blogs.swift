//
//  Blogs.swift
//  Jet2TT
//
//  Created by Rahul Patil on 11/05/20.
//  Copyright © 2020 Rahul Patil. All rights reserved.
//

import Foundation

typealias Blogs = [Blog]

// MARK: - Blog
struct Blog: Codable, Hashable {
    let id: String
    let createdAt: String
    let content: String
    let comments: Int
    let likes: Int
    let media: [Media]
    let user: [User]

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case content
        case comments
        case likes
        case media
        case user
    }
}

// MARK: - Media
struct Media: Codable, Hashable {
    let id: String
    let blogId: String
    let createdAt: String
    let image: URL
    let title: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case id
        case blogId
        case createdAt
        case image
        case title
        case url
    }
}

// MARK: - User
struct User: Codable, Hashable {
    let id: String
    let blogId: String
    let createdAt: String
    let name: String
    let avatar: URL
    let lastname: String
    let city: String
    let designation: String
    let about: String

    enum CodingKeys: String, CodingKey {
        case id
        case blogId
        case createdAt
        case name
        case avatar
        case lastname
        case city
        case designation
        case about
    }
}
