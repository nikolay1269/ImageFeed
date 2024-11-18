//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Nikolay on 22.09.2024.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
}
