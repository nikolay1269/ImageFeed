//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Nikolay on 16.09.2024.
//

import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private var task: URLSessionTask?
    private var lastCode: String?
    private init() {}
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        
        let baseURL = URL(string: "https://unsplash.com")
        guard let url = URL(string: "/oauth/token"
                      + "?client_id=\(Constants.accessKey)"
                      + "&&client_secret=\(Constants.secretKey)"
                      + "&&redirect_uri=\(Constants.redirectURI)"
                      + "&&code=\(code)"
                      + "&&grant_type=authorization_code",
                      relativeTo: baseURL)
        else {
            assertionFailure("Failed to create URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>)->Void) {
        
        assert(Thread.isMainThread)
        guard lastCode != code else {
            print("[fetchOAuthToken]: Dublicate request with same code: \(code)")
            completion(.failure(NetworkServicesError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        
        guard
            let request = makeOAuthTokenRequest(code: code)
        else {
            print("[fetchOAuthToken]: Invalid request with code: \(code)")
            completion(.failure(NetworkServicesError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objestTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            
            switch(result) {
            case .success(let authResult):
                completion(.success(authResult.accessToken))
            case .failure(let error):
                completion(.failure(error))
            }
            self?.task = nil
            self?.lastCode = nil
        }
        
        self.task = task
        task.resume()
    }
}
