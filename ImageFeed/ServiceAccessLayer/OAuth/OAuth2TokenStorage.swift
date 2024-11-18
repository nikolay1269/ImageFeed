//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Nikolay on 22.09.2024.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    private let tokenKey: String = "Auth token"
    private init() {}
    
    var token: String? {
        
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            let isSuccess = KeychainWrapper.standard.set(newValue ?? "", forKey: tokenKey)
            guard isSuccess else {
                print("[OAuth2TokenStorage]: Error while saving token in keychain")
                return
            }
        }
    }
}
