//
//  PfofileViewController.swift
//  ImageFeed
//
//  Created by Nikolay on 18.07.2024.
//

import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set}
    func loadImageProfile(url: URL)
    func updateProfileDetails(name: String, email: String, bio: String)
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    
    private var fullNameLabel: UILabel?
    private var emailLabel: UILabel?
    private var profileImageView: UIImageView?
    private var descriptionLabel: UILabel?
    var presenter: ProfilePresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView = addProfileImageView()
        fullNameLabel = addFullNameLabel()
        emailLabel = addEmailLabel()
        descriptionLabel = addDescriptionLabel()
        addExitButton()
        presenter?.viewDidLoad()
    }
    
    private func addProfileImageView() -> UIImageView? {
        let imageView = UIImageView(image: UIImage(named: "Stub"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        let topAnchor = imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32)
        let widthAnchor = imageView.widthAnchor.constraint(equalToConstant: 70)
        let heightAnchor = imageView.heightAnchor.constraint(equalToConstant: 70)
        let leadingAnchor = imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        NSLayoutConstraint.activate([topAnchor, widthAnchor, heightAnchor, leadingAnchor])
        return imageView
    }
    
    private func addFullNameLabel() -> UILabel? {
        let fullNameLabel = UILabel()
        fullNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fullNameLabel)
        fullNameLabel.textColor = UIColor(named: "YPWhite")
        fullNameLabel.font = UIFont(name: "SF Pro Bold", size: 23)
        fullNameLabel.setTextSpacingBy(value: -0.08)
        if let profileImageView = profileImageView {
            fullNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
            fullNameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor).isActive = true
        }
        return fullNameLabel
    }
    
    private func addEmailLabel() -> UILabel? {
        let emailLabel = UILabel()
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emailLabel)
        emailLabel.textColor = UIColor(named: "YPGray")
        emailLabel.font = UIFont(name: "SF Pro Regular", size: 13)

        if let fullNameLabel = fullNameLabel {
            emailLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 8).isActive = true
            emailLabel.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor).isActive = true
        }
        return emailLabel
    }
    
    private func addExitButton() {
        let exitButton = UIButton.systemButton(with: UIImage(named: "Exit") ?? UIImage(), target: self, action: #selector(exitButtonTapped))
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        exitButton.tintColor = .red
        view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: exitButton.trailingAnchor, constant: 16).isActive = true
        if let profileImageView = profileImageView {
            exitButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        }
    }
    
    private func addDescriptionLabel() -> UILabel? {
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        descriptionLabel.textColor = UIColor(named: "YPWhite")
        descriptionLabel.font = UIFont(name: "SF Pro Regular", size: 13)
        if let emailLabel = emailLabel {
            descriptionLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8).isActive = true
            descriptionLabel.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor).isActive = true
        }
        return descriptionLabel
    }
    
    func updateProfileDetails(name: String, email: String, bio: String) {
        
        self.fullNameLabel?.text = name
        self.emailLabel?.text = email
        self.descriptionLabel?.text = bio
    }
    
    @IBAction private func exitButtonTapped() {
        presenter?.logout()
        switchToAuthScreen()
    }
    
    private func switchToAuthScreen() {
        
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }
    
    func loadImageProfile(url: URL) {
        if isViewLoaded {
            profileImageView?.kf.setImage(with: url)
        }
    }
}
