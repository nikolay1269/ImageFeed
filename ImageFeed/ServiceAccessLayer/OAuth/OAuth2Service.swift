//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Nikolay on 16.09.2024.
//

import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private init() {}
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest {
        let baseURL = URL(string: "https://unsplash.com")
        let url = URL(string: "/oauth/token"
                      + "?client_id=\(Constants.accessKey)"
                      + "&&client_secret=\(Constants.secretKey)"
                      + "&&redirect_uri=\(Constants.redirectURI)"
                      + "&&code=\(code)"
                      + "&&grant_type=authorization_code",
                      relativeTo: baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, competion: @escaping (Result<String, Error>)->Void) {
        
        let request = makeOAuthTokenRequest(code: code)
        let task = URLSession.shared.data(for: request) { result in
            switch(result) {
            case .success(let data):
                do {
                    let token = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data).accessToken
                    competion(.success(token))
                } catch {
                    competion(.failure(error))
                }
            case .failure(let error):
                competion(.failure(error))
            }
        }
        
        task.resume()
    }
}
