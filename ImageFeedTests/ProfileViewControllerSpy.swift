//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Nikolay on 15.11.2024.
//

@testable import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    
    var presenter: ImageFeed.ProfilePresenterProtocol?
    var loadImageProfileCalled: Bool = false
    var updateProfileDetails: Bool = false
    
    func loadImageProfile(url: URL) {
        loadImageProfileCalled = true
    }
    
    func updateProfileDetails(name: String, email: String, bio: String) {
        updateProfileDetails = true
    }
}
