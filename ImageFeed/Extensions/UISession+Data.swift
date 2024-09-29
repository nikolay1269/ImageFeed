//
//  UISession+Data.swift
//  ImageFeed
//
//  Created by Nikolay on 22.09.2024.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    
    func data(for request: URLRequest, completion: @escaping (Result<Data, Error>)->Void) -> URLSessionTask {
        
        let fulfillCompetionOnMainThread: (Result<Data, Error>) -> Void =
        { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                
                if 200..<300 ~= statusCode {
                    fulfillCompetionOnMainThread(.success(data))
                } else {
                    print(String(data: data, encoding: .utf8) ?? "Error from server with code: \(statusCode)")
                    fulfillCompetionOnMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompetionOnMainThread(.failure(NetworkError.urlRequestError(error)))
            } else  {
                print("URL Session erro")
                fulfillCompetionOnMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        
        return task
    }
}
