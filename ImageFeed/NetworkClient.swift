//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Nikolay on 21.09.2024.
//

import Foundation

protocol NetworkRouting {
    func fetch(urlRequest: URLRequest, handler: @escaping (Result<Data, Error>)->Void)
}

struct NetworkClient: NetworkRouting {
    
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetch(urlRequest: URLRequest, handler: @escaping (Result<Data, Error>) -> Void) {
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            if let error = error {
                handler(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode < 200 || response.statusCode >= 300 {
                
                handler(.failure(NetworkError.codeError))
            }
            
            if let data = data {
                handler(.success(data))
            }
        }
        
        task.resume()
    }
}
