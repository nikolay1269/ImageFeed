//
//  Profile.swift
//  ImageFeed
//
//  Created by Nikolay on 17.10.2024.
//

import Foundation

struct Profile {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String
    var name: String {
        return firstName + " " + lastName
    }
    var loginName: String {
        return "@" + username
    }
    
    init(profileResult: ProfileResult) {
        username = profileResult.username ?? ""
        firstName = profileResult.firstName ?? ""
        lastName = profileResult.lastName ?? ""
        bio = profileResult.bio ?? ""
    }
}
