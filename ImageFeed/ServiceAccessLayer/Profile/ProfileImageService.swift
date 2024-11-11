//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Nikolay on 19.10.2024.
//

import Foundation

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    private init() {}
    private (set) var avatarURL: String?
    private var task: URLSessionTask?
    private var lastUsername: String?
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    func makeProfileImageRequest(username: String, authToken: String) -> URLRequest? {
        
        guard let url = URL(string: "/users/\(username)", relativeTo: Constants.defaultBaseURL) else {

            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authToken)",  forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping(Result<String, Error>)->Void) {
        
        assert(Thread.isMainThread)
        if (task != nil) {
            if lastUsername != username {
                task?.cancel()
            } else {
                print("[fetchProfileImageURL]: Dublicate request with the same username: \(username)")
                completion(.failure(NetworkServicesError.invalidRequest))
            }
        } else {
            if lastUsername == username {
                print("[fetchProfileImageURL]: Task is nil with the same username: \(username)")
                completion(.failure(NetworkServicesError.invalidRequest))
            }
        }
        
        lastUsername = username
        guard let token = OAuth2TokenStorage.shared.token, token.count > 0, let request = makeProfileImageRequest(username: username, authToken: token) else {
            
            print("[fetchProfileImageURL]: Invalid request with username: \(username)")
            completion(.failure(NetworkServicesError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objestTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            
            switch(result) {
            case .success(let userResult):
                let imageURL = userResult.profileImage.small
                self?.avatarURL = imageURL
                NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: self, userInfo: ["URL": imageURL])
            case .failure(let error):
                completion(.failure(error))
            }
            self?.task = nil
            self?.lastUsername = nil
        }
        
        self.task = task
        task.resume()
    }
    
    func clearAvatarURL() {
        avatarURL = nil
    }
}
