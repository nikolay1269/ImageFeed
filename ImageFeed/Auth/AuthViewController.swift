//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Nikolay on 16.08.2024.
//

import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    private let webViewControllerSegueIdentifier = "ShowWebView"
    weak var delegate: AuthViewControllerDelegate?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureBackButton()
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button_white")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button_white")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YPBlack")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == webViewControllerSegueIdentifier {
            if let vc = segue.destination as? WebViewViewController {
                vc.delegate = self
            } else {
                fatalError("Error showing webViewViewController")
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        
        UIBlockingProgressHUD.show()
        
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }

            switch result {
            case .success(let token):
                OAuth2TokenStorage.shared.token = token
                self.delegate?.didAuthenticate(self)
                vc.dismiss(animated: true)
            case .failure:
                self.showErorrAlert(vc: vc)
            }
        }
    }
    
    private func showErorrAlert(vc: UIViewController) {
        let alert = UIAlertController(title: "Что-то пошло не так",
                                      message: "Не удалось войти в систему",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { action in
            vc.dismiss(animated: true)
        }
        alert.addAction(action)
        vc.present(alert, animated: true)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
