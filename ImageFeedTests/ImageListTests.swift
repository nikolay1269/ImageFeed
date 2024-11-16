//
//  ImagesListTests.swift
//  ImageFeedTests
//
//  Created by Nikolay on 16.11.2024.
//

@testable import ImageFeed
import XCTest

final class ImageListTests: XCTestCase {
    
    func testPresenterCallsLoadNextPhotosPage() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        guard let imagesListViewController = imagesListViewController as? ImagesListViewController else { return }
        let imageListPresenter = ImageListPresenterSpy()
        imagesListViewController.presenter = imageListPresenter
        imageListPresenter.view = imagesListViewController
        
        //when
        _ = imagesListViewController.view
        
        //then
        XCTAssertTrue(imageListPresenter.loadNextPhotosPageCalled)
    }
    
    func testPhotoProperties() {
        //given
        let presenterFake = ImageListPresenterFake()
        let photo = Photo(id: "9s8uf09sd8",
                          size: CGSize(width: 100, height: 100),
                          createdAt: Date(timeIntervalSinceReferenceDate: 753435870.602032),
                          welcomeDescription: "asdfsdf",
                          thumbnailURL: "https://thumbnailImage.ru",
                          largeImageURL: "https://largeImage.ru",
                          isLiked: true)
        
        //when
        presenterFake.loadPhoto(photo: photo)
        
        //then
        XCTAssertEqual(presenterFake.photoThumbnailURLForIndex(0), URL(string: "https://thumbnailImage.ru"))
        XCTAssertEqual(presenterFake.photoIsLikedForIndex(0), true)
        XCTAssertEqual(presenterFake.photoLargeURLForIndex(0), URL(string: "https://largeImage.ru"))
        XCTAssertEqual(presenterFake.photoCreatedAtDateTextForIndex(0), "16 нояб. 2024 г.")
        XCTAssertEqual(presenterFake.photosCount(), 1)
    }
    
    func testChangeLike() {
        //given
        let presenterFake = ImageListPresenterFake()
        let photo = Photo(id: "9s8uf09sd8",
                          size: CGSize(width: 100, height: 100),
                          createdAt: Date(timeIntervalSinceReferenceDate: 753435870.602032),
                          welcomeDescription: "asdfsdf",
                          thumbnailURL: "https://thumbnailImage.ru",
                          largeImageURL: "https://largeImage.ru",
                          isLiked: false)
        presenterFake.loadPhoto(photo: photo)
        let expectation = XCTestExpectation()
        var result = false
        
        //when
        presenterFake.changeLike(for: 0) { _, isLike in
            result = isLike
            expectation.fulfill()
        }
        
        //then
        wait(for: [expectation], timeout: 3.0)
        XCTAssertEqual(result, true)
    }
}
