//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Nikolay on 22.09.2024.
//

import Foundation

struct OAuthTokenResponseBody: Codable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope = "scope"
        case createdAt = "created_at"
    }
}
