//
//  ImageListPresenterFake.swift
//  ImageFeedTests
//
//  Created by Nikolay on 16.11.2024.
//

@testable import ImageFeed
import Foundation

final class ImageListPresenterFake: ImageListPresenterProtocol {
    var view: ImageFeed.ImageListViewControllerProtocol?
    var photos: [Photo] = []
    
    func viewDidLoad() {
    }
    
    func changeLike(for index: Int, completion: @escaping (Result<Void, Error>, Bool) -> Void) {
        if photos.count > 0 {
            completion(.success(()), !photos[0].isLiked)
        }
    }
    
    func loadPhoto(photo: Photo) {
        photos = [photo]
    }
    
    func loadNextPhotosPage() {
    }
    
    func photosCount() -> Int {
        return photos.count
    }
    
    func photoThumbnailURLForIndex(_ index: Int) -> URL? {
        guard let url = URL(string: photos[index].thumbImageURL) else {
            return nil
        }
        return url
    }
    
    func photoIsLikedForIndex(_ index: Int) -> Bool {
        photos[index].isLiked
    }
    
    func photoCreatedAtDateTextForIndex(_ index: Int) -> String? {
        
        guard let date = photos[index].createdAt else {
            return ""
        }
        return dateFormatter.string(from: date)
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    func photoLargeURLForIndex(_ index: Int) -> URL? {
        guard let url = URL(string: photos[index].largeImageURL) else {
            return nil
        }
        return url
    }
}

