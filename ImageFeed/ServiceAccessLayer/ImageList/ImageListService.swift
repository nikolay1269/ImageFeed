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
    private var task: URLSessionTask?
    
    
    private init() {}
    
    func makePhotosNextPageRequest(page: Int, authToken: String) -> URLRequest? {
        
        guard let url = URL(string: "/photos?page=\(page)&per_page=\(photosPerPage)", relativeTo: Constants.defaultBaseURL) else {
            
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authToken)",  forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchPhotosNextPage() {
        
        assert(Thread.isMainThread)
        let nextPage = (lastLoadedPage ?? 0) + 1
        if (task != nil) {
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
            self?.task = nil
            self?.lastLoadingPage = 0
        }
        self.task = task
        task.resume()
    }
}
