//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Nikolay on 23.09.2024.
//

import UIKit

final class SplashViewController: UIViewController {
    
    private let showAuthenticationScreenSegueIdentifier = "showAuthenticationScreenSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 26.0 / 255.0, green: 27.0 / 255.0, blue: 34.0 / 255.0, alpha: 1.0)
        addSplashLogoImage()
    }
    
    private func addSplashLogoImage() {
        let image = UIImage(named: "splash_logo")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        let centerXAnchor = imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        let centerYAnchor = imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        NSLayoutConstraint.activate([centerXAnchor, centerYAnchor])
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = OAuth2TokenStorage.shared.token, token.count > 0 {
            fetchProfile(token)
        } else {
            presentAuthViewController()
        }
    }
    
    private func presentAuthViewController() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            print("[presentAuthViewController]: Error while presenting Auth View Controller")
            return
        }
        
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        self.present(authViewController, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
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

extension SplashViewController: AuthViewControllerDelegate {
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = OAuth2TokenStorage.shared.token, token.count > 0 else {
            return
        }
        
        fetchProfile(token)
    }
    
    func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            self.switchToTabbarController()
            switch result {
            case .success(let profile):
                ProfileService.shared.profile = profile
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { result in
                    switch result {
                    case .success(let imageURL):
                        print("Image url:\(imageURL) loaded succesfully")
                    case .failure(let error):
                        print("[SplashViewController-fetchProfile]: Error: \(error)")
                    }
                }
            case .failure(let error):
                print("[SplashViewController-fetchProfile]: Error: \(error)")
            }
        }
    }
}
