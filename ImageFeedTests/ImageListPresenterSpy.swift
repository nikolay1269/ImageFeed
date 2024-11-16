//
//  ImageListPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Nikolay on 16.11.2024.
//

@testable import ImageFeed
import Foundation

final class ImageListPresenterSpy: ImageListPresenterProtocol {
    var view: ImageFeed.ImageListViewControllerProtocol?
    
    var loadNextPhotosPageCalled = false
    
    func viewDidLoad() {
        loadNextPhotosPage()
    }
    
    func changeLike(for index: Int, completion: @escaping (Result<Void, Error>, Bool) -> Void) {
        
    }
    
    func loadNextPhotosPage() {
        loadNextPhotosPageCalled = true
    }
    
    func photosCount() -> Int {
        return 0
    }
    
    func photoThumbnailURLForIndex(_ index: Int) -> URL? {
        return nil
    }
    
    func photoIsLikedForIndex(_ index: Int) -> Bool {
        return false
    }
    
    func photoCreatedAtDateTextForIndex(_ index: Int) -> String? {
        return nil
    }
    
    func photoLargeURLForIndex(_ index: Int) -> URL? {
        return nil
    }
}
