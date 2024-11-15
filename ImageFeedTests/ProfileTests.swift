//
//  ProfileTests.swift
//  ImageFeedTests
//
//  Created by Nikolay on 14.11.2024.
//

@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssert(presenter.isViewDidLoadCalled)
    }
    
    func testNotificationCallsLoadImageProfile() {
        //given
        let viewControllerSpy = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(view: viewControllerSpy)
        viewControllerSpy.presenter = presenter
        
        //when
        let profileImageNotificationExpectation = XCTNSNotificationExpectation(name: ProfileImageService.didChangeNotification)
        NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: self, userInfo: ["URL": "https://ya.ru"])
        
        //then
        wait(for: [profileImageNotificationExpectation], timeout: 3.0)
        XCTAssertTrue(viewControllerSpy.loadImageProfileCalled)
    }
    
    func testPresenterCallsUpdateProfileAndLoadImage() {
        //given
        let viewControllerSpy = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(view: viewControllerSpy)
        viewControllerSpy.presenter = presenter
        ProfileImageService.shared.avatarURL = "https://ya.ru"
        let profileResult = ProfileResult(username: "ivanov", firstName: "Иван", lastName: "Иванов", bio: "")
        ProfileService.shared.profile = Profile(profileResult: profileResult)
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewControllerSpy.loadImageProfileCalled && viewControllerSpy.updateProfileDetails)
    }
}
