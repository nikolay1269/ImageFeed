//
//  ProfilePresenterSpy.swift
//  ImageFeedTests
//
//  Created by Nikolay on 15.11.2024.
//

@testable import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    
    var view: ImageFeed.ProfileViewControllerProtocol?
    var isViewDidLoadCalled = false

    func viewDidLoad() {
        isViewDidLoadCalled = true
    }
    
    func logout() {
        
    }
}
