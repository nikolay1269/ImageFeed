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
                    print("[data]: NetworkError:\(String(data: data, encoding: .utf8) ?? "") response status \(statusCode)")
                    fulfillCompetionOnMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                print("[data]: NetworkError: \(error.localizedDescription)")
                fulfillCompetionOnMainThread(.failure(NetworkError.urlRequestError(error)))
            } else  {
                print("[data]: URLSessionError")
                fulfillCompetionOnMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        
        return task
    }
    
    func objestTask<T: Decodable>(for request: URLRequest, completion: @escaping(Result<T, Error>)->Void) -> URLSessionTask {
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch(result) {
            case .success(let data):
                do {
                    let data = try decoder.decode(T.self, from: data)
                    completion(.success(data))
                } catch {
                    print("[dataTask] DecodingError: \(error), Data: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("[dataTask]: NetworkError: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        return task
    }
}
