//
//  Constants.swift
//  ImageFeed
//
//  Created by Nikolay on 13.08.2024.
//

import Foundation

enum Constants {
    static let secretKey = "jWCCO5VhY-HgKAE9vrGahgEQZgTE5mDeuV2Rqot3cNE"
    static let accessKey = "9jYKGgHcEQ6NSgnQUw2A94dIs_I0WdT83cpBwBwCL-Q"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")
    static let authorizeURL = "/oauth/authorize/native"
    static let codeFieldName = "code"
}

enum NetworkServicesError: Error {
    case invalidRequest
}

struct Queue<Element> {
    var items: [Element] = []
    
    mutating func addToBack(_ item: Element) {
        items.append(item)
    }
    
    mutating func removeFront() -> Element {
        return items.removeFirst()
    }
}

extension Queue {
    
    var frontItem: Element? {
        return items.isEmpty ? nil: items[0]
    }
}
