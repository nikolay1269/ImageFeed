//
//  ImageListPresenter.swift
//  ImageFeed
//
//  Created by Nikolay on 15.11.2024.
//

import Foundation

protocol ImageListPresenterProtocol {
    var view: ImageListViewControllerProtocol? { get set}
    func viewDidLoad()
    func changeLike(for index: Int, completion: @escaping (Result<Void, Error>, Bool)->Void)
    func loadNextPhotosPage()
    func photosCount() -> Int
    func photoThumbnailURLForIndex(_ index: Int) -> URL?
    func photoIsLikedForIndex(_ index: Int) -> Bool
    func photoCreatedAtDateTextForIndex(_ index: Int) -> String?
    func photoLargeURLForIndex(_ index: Int) -> URL?
}

final class ImageListPresenter: ImageListPresenterProtocol {
        
    weak var view: ImageListViewControllerProtocol?
    var photos: [Photo] = []
    
    func viewDidLoad() {
        addObserver()
        loadNextPhotosPage()
        view?.initTableView()
    }
    
    func loadNextPhotosPage() {
        ImageListService.shared.fetchPhotosNextPage()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(forName: ImageListService.didChangedNotification, object: nil, queue: .main) { [weak self] _ in
            
            guard let self = self else { return }
            
            let oldCount = self.photosCount()
            let newCount = self.loadedPhotosCount()
            self.photos = ImageListService.shared.photos
            self.view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
        }
    }
    
    func changeLike(for index: Int, completion: @escaping (Result<Void, Error>, Bool)->Void) {
        
        let photo = photos[index]
        ImageListService.shared.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            
            completion(result, !photo.isLiked)
        }
    }
    
    func photosCount() -> Int {
        photos.count
    }
    
    private func loadedPhotosCount() -> Int {
        ImageListService.shared.photos.count
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
