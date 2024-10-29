//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Nikolay on 18.08.2024.
//

import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let unsplashTokenURLString = "https://unsplash.com/oauth/token"
}

final class WebViewViewController: UIViewController {
    
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    private var estimatedprogressObservation: NSKeyValueObservation?
    
    weak var delegate: WebViewViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else  {
            print("Incorrect url components from string")
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        guard let url = urlComponents.url else {
            print("Incorrect url from url components")
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
        
        estimatedprogressObservation = webView.observe(\.estimatedProgress, options: [], changeHandler: { [weak self] _, _ in
            guard let self = self else { return }
            self.updateProgress()
        })
    }
    
    @IBAction private func didTapBackButton() {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
}

extension WebViewViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String?  {
        
        if let url = navigationAction.request.url,
           let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == Constants.authorizeURL,
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == Constants.codeFieldName}) {
            return codeItem.value
        } else {
            return nil
        }
    }
}
