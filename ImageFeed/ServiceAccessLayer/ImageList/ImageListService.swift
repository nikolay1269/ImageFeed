//
//  ImageListService.swift
//  ImageFeed
//
//  Created by Nikolay on 04.11.2024.
//

import Foundation

final class ImageListService {

    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var lastLoadingPage: Int = 0

    static let shared = ImageListService()
    static let didChangedNotification = Notification.Name(rawValue: "ImageListServiceDidChange")
    private let photosPerPage = 10
    private var photosNextPageTask: URLSessionTask?
    private var changeLikeTask: URLSessionTask?
    private var lastPhotoId: String?
    
    private init() {}
    
    private func makePhotosNextPageRequest(page: Int, authToken: String) -> URLRequest? {
        
        guard let url = URL(string: "/photos?page=\(page)&per_page=\(photosPerPage)", relativeTo: Constants.defaultBaseURL) else {
            
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authToken)",  forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func makeChangeLikeRequest(photoId: String, isLike: Bool, authToken: String) -> URLRequest? {
        
        guard let url = URL(string: "/photos/\(photoId)/like", relativeTo: Constants.defaultBaseURL) else {
            
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        if (isLike) {
            request.httpMethod = "POST"
        } else {
            request.httpMethod = "DELETE"
        }
        request.setValue("Bearer \(authToken)",  forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchPhotosNextPage() {
        
        assert(Thread.isMainThread)
        let nextPage = (lastLoadedPage ?? 0) + 1
        if (photosNextPageTask != nil) {
            print("[fetchPhotosNextPage]: Dublicate request while prevois has not loaded for page: \(lastLoadingPage)")
            return
        } else {
            if lastLoadingPage == nextPage {
                print("[fetchPhotosNextPage]: Task is nil with the same page: \(lastLoadingPage)")
                return
            }
        }
        
        lastLoadingPage = nextPage
        guard let token = OAuth2TokenStorage.shared.token, token.count > 0, let request = makePhotosNextPageRequest(page: nextPage, authToken: token) else {
            
            print("[fetchPhotosNextPage]: Invalid request with page: \(nextPage)")
            return
        }
        
        let task = URLSession.shared.objestTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            
            switch(result) {
            case .success(let photoResults):
                for photoResult in photoResults {
                    var photo = Photo(photoRusult: photoResult)
                    photo.createdAt = photoResult.createdAt.dateFromString()
                    self?.photos.append(photo)
                }
                self?.lastLoadedPage = nextPage
                NotificationCenter.default.post(name: ImageListService.didChangedNotification, object: self, userInfo: ["photos": self?.photos ?? []])
            case .failure(let error):
                print(error)
            }
            self?.photosNextPageTask = nil
            self?.lastLoadingPage = 0
        }
        self.photosNextPageTask = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>)->Void) {
        
        assert(Thread.isMainThread)
        guard lastPhotoId != photoId else {
            print("[changeLike]: Dublicate request with same photoId: \(photoId)")
            completion(.failure(NetworkServicesError.invalidRequest))
            return
        }
        changeLikeTask?.cancel()
        lastPhotoId = photoId
        
        guard let token = OAuth2TokenStorage.shared.token, token.count > 0, let request = makeChangeLikeRequest(photoId: photoId, isLike: isLike, authToken: token) else {
            
            print("[changeLike]: Invalid request with photoId: \(photoId)")
            return
        }
        
        let task = URLSession.shared.data(for: request) {[weak self] (result:Result<Data, Error>) in
            
            guard let self = self else { return }
            
            switch(result) {
            case .success:
                self.changePhotoLikeState(photoId: photoId)
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
            self.changeLikeTask = nil
            self.lastPhotoId = nil
        }
        
        self.changeLikeTask = task
        task.resume()
    }
    
    private func changePhotoLikeState(photoId: String) {
        if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
            let photo = self.photos[index]
            let newPhoto = Photo(id: photo.id, size: photo.size, createdAt: photo.createdAt, welcomeDescription: photo.welcomeDescription, thumbnailURL: photo.thumbImageURL, largeImageURL: photo.largeImageURL, isLiked: !photo.isLiked)
            self.photos[index] = newPhoto
        }
    }
    
    func clearPhotos() {
        photos = []
        lastLoadedPage = nil
        lastLoadingPage = 0
        changeLikeTask?.cancel()
        changeLikeTask = nil
        photosNextPageTask?.cancel()
        photosNextPageTask = nil
    }
}
