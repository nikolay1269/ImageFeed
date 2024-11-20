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
        0
    }
    
    func photoThumbnailURLForIndex(_ index: Int) -> URL? {
        nil
    }
    
    func photoIsLikedForIndex(_ index: Int) -> Bool {
        false
    }
    
    func photoCreatedAtDateTextForIndex(_ index: Int) -> String? {
        nil
    }
    
    func photoLargeURLForIndex(_ index: Int) -> URL? {
        nil
    }
}
