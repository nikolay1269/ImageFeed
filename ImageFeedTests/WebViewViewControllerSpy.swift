//
//  WebViewViewControllerSpy.swift
//  ImageFeed
//
//  Created by Nikolay on 14.11.2024.
//

@testable import ImageFeed
import Foundation

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    var isLoadRequestCalled = false
    
    func load(request: URLRequest) {
        isLoadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
    }
    
    func setProgressHidden(_ isHidden: Bool) {
    }
}
