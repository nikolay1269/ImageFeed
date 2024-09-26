//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Nikolay on 22.09.2024.
//

import Foundation

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: "token")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "token")
        }
    }
}
