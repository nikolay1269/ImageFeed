//
//  WebViewPresenterSpy.swift
//  ImageFeed
//
//  Created by Nikolay on 13.11.2024.
//

@testable import ImageFeed
import Foundation

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        
    }
    
    func code(url: URL) -> String? {
        return nil
    }
}
