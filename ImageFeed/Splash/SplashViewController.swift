//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Nikolay on 23.09.2024.
//

import UIKit

final class SplashViewController: UIViewController {
    
    private let showAuthenticationScreenSegueIdentifier = "showAuthenticationScreenSegueIdentifier"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if userIsLoggedIn() {
            switchToTabbarController()
            
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func userIsLoggedIn() -> Bool {
        return OAuth2TokenStorage.shared.token != nil
    }
    
    private func switchToTabbarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabbarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabbarController
    }
}

extension SplashViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            
            guard
                let navigationViewController = segue.destination as? UINavigationController,
                let authenticateViewController = navigationViewController.viewControllers.first as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier))")
                return
            }
            
            authenticateViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}


extension SplashViewController: AuthViewControllerDelegate {
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        switchToTabbarController()
    }
}
