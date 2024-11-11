//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Nikolay on 04.11.2024.
//

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool
}
