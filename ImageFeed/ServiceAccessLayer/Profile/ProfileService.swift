//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Nikolay on 17.10.2024.
//

import Foundation

struct ProfileResult: Codable {
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
                completion(.failure(AuthServiceError.invalidRequest))
            }
        } else {
            if lastToken == token {
                completion(.failure(AuthServiceError.invalidRequest))
            }
        }
        lastToken = token
        guard let request = makeProfileRequest(authToken: token) else {
            
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.data(for: request) { [weak self] result in
         
            DispatchQueue.main.async {
                switch(result) {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let dataStr = String(data: data, encoding: .utf8)
                        let profileResult = try decoder.decode(ProfileResult.self, from: data)
                        let profile = Profile(profileResult: profileResult)
                        completion(.success(profile))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
                self?.task = nil
                self?.lastToken = nil
            }
        }
        self.task = task
        task.resume()
    }
}
