//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Nikolay on 17.10.2024.
//

import Foundation

struct ProfileResult: Decodable {
    let username: String?
    let firstName: String?
    let lastName: String?
    let bio: String?
}

final class ProfileService {
    
    static let shared = ProfileService()
    private var task: URLSessionTask?
    private var lastToken: String?
    var profile: Profile?
    private init() {}
    
    func makeProfileRequest(authToken: String) -> URLRequest? {
        
        guard let url = URL(string: "/me", relativeTo: Constants.defaultBaseURL) else {
            assertionFailure("Failed to create URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>)->Void) {
        
        assert(Thread.isMainThread)
        if(task != nil) {
            if lastToken != token {
                task?.cancel()
            } else {
                print("[fetchProfile]: Dublicate request with the same token: \(token)")
                completion(.failure(NetworkServicesError.invalidRequest))
            }
        } else {
            if lastToken == token {
                print("[fetchProfile]: Task is nil with the same token: \(token)")
                completion(.failure(NetworkServicesError.invalidRequest))
            }
        }
        lastToken = token
        guard let request = makeProfileRequest(authToken: token) else {
            
            print("[fetchProfile]: Invalid request with token: \(token)")
            completion(.failure(NetworkServicesError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objestTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            
            switch(result) {
            case .success(let profileResult):
                let profile = Profile(profileResult: profileResult)
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
            self?.task = nil
            self?.lastToken = nil
        }
        
        self.task = task
        task.resume()
    }

    func clearProfile() {
        profile = nil
        lastToken = nil
        task?.cancel()
        task = nil
    }
}
