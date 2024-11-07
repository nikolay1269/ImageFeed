//
//  Photo.swift
//  ImageFeed
//
//  Created by Nikolay on 04.11.2024.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    var createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
    
    init(photoRusult: PhotoResult) {
        id = photoRusult.id
        size = CGSize(width: photoRusult.width, height: photoRusult.height)
        createdAt = Date()
        welcomeDescription = photoRusult.description
        thumbImageURL = photoRusult.urls.thumb
        largeImageURL = photoRusult.urls.full
        isLiked = photoRusult.likedByUser
    }
}
