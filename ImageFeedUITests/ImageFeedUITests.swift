//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Nikolay on 16.11.2024.
//

import XCTest

final class ImageFeedUITests: XCTestCase {

    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
       
        continueAfterFailure = false
        app.launchArguments = ["testMode"]
        app.launch()
    }
    
    func testAuth() throws {
        
        app.buttons["Authenticate"].tap()
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText("infnick@list.ru")
        sleep(1)
        app.buttons["Done"].tap()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 1))
        passwordTextField.tap()
        passwordTextField.typeText("MdvfD8TgJw@MUH!3")
        
        webView.buttons["Login"].tap()
        let cell = app.tables.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
    }
    
    func testFeed() throws {
        
        _ = app.tables.firstMatch.waitForExistence(timeout: 3)
        
        app.swipeUp()
        
        sleep(10)
        
        let likeButtonInactive = app.tables.children(matching: .cell).element(boundBy: 1).buttons["Favorite inactive"]
        likeButtonInactive.tap()
        sleep(2)
        
        let likeButtonActive = app.tables.children(matching: .cell).element(boundBy: 1).buttons["Favorite active"]
        likeButtonActive.tap()
        
        let cell = app.tables.children(matching: .cell).element(boundBy: 0)
        cell.tap()
        
        sleep(5)
        
        app.pinch(withScale: 2.0, velocity: 1)
        app.pinch(withScale: 0.5, velocity: -1)
        
        app.buttons["nav back button white"].tap()
    }
    
    func testProfile() throws {
        
        _ = app.tables.firstMatch.waitForExistence(timeout: 3)
        
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        let logoutButton = app.buttons["Exit"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
        
        logoutButton.tap()
        app.alerts["Выход из профиля"].scrollViews.otherElements.buttons["Да"].tap()
        
        XCTAssertTrue(app.buttons["Authenticate"].waitForExistence(timeout: 3))
    }
}
