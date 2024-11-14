//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Nikolay on 13.11.2024.
//

@testable import ImageFeed
import XCTest

final class WebViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
        
        //given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper(configuration: AuthConfiguration.standard)
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewController.isLoadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        //given
        let authHelper = AuthHelper(configuration: AuthConfiguration.standard)
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssertFalse(shouldHideProgress)
    }
    
    
    
    func testProgressHiddenWhenOne() {
        //given
        let authHelper = AuthHelper(configuration: AuthConfiguration.standard)
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        //given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        //when
        let url = authHelper.authURL()
        let urlString = url?.absoluteString
        
        //then
        XCTAssertTrue(urlString?.contains(configuration.authURLString) ?? false)
        XCTAssertTrue(urlString?.contains(configuration.accessKey) ?? false)
        XCTAssertTrue(urlString?.contains(configuration.redirectURI) ?? false)
        XCTAssertTrue(urlString?.contains(Constants.codeFieldName) ?? false)
        XCTAssertTrue(urlString?.contains(configuration.accessScope) ?? false)
    }
    
    func testCodeFromURL() {
        //given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents.url!
        
        //when
        let authHelper = AuthHelper(configuration: AuthConfiguration.standard)
        
        //then
        let code = authHelper.code(from: url) 
        XCTAssertEqual(code, "test code")
    }
}
