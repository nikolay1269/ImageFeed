//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Nikolay on 16.09.2024.
//

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

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
        if(task != nil) {
            if lastCode != code {
                task?.cancel()
            } else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        lastCode = code
        guard
            let request = makeOAuthTokenRequest(code: code)
        else {
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
                        let token = try decoder.decode(OAuthTokenResponseBody.self, from: data).accessToken
                        completion(.success(token))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
                self?.task = nil
                self?.lastCode = nil
            }
        }
        self.task = task
        task.resume()
    }
}
