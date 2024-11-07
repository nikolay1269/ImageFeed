//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Nikolay on 06.11.2024.
//

@testable import ImageFeed
import XCTest

final class ImageFeedTests: XCTestCase {

    func testFetchPhotos() throws {
        let service = ImageListService()
        
        let expectation = self.expectation(description: "Wait for Notification")
        NotificationCenter.default.addObserver(forName: ImageListService.didChangedNotification, object: nil, queue: .main) { _ in
            expectation.fulfill()
        }
        
        service.fetchPhotosNextPage()
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(service.photos.count, 10)
    }
}
