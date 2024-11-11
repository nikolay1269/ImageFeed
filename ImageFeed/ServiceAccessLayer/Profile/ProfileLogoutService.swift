//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Nikolay on 10.11.2024.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    
    static let shared = ProfileLogoutService()
    
    private init() {}
    
    func logout() {
        cleanCookies()
        OAuth2TokenStorage.shared.token = nil
        ProfileService.shared.clearProfile()
        ProfileImageService.shared.clearAvatarURL()
        ImageListService.shared.clearPhotos()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
