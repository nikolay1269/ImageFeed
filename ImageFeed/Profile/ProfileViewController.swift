//
//  PfofileViewController.swift
//  ImageFeed
//
//  Created by Nikolay on 18.07.2024.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private var fullNameLabel: UILabel?
    private var emailLabel: UILabel?
    private var profileImageView: UIImageView?
    private var descriptionLabel: UILabel?
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        addObserver()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addObserver()
    }
    
    deinit {
        removeObserver()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector:
                                                    #selector(updateAvatar(notification:)),
                                                 name: ProfileImageService.didChangeNotification,
                                                 object: nil)
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: ProfileImageService.didChangeNotification, object: nil)
    }
    
    @objc
    private func updateAvatar(notification: Notification) {
        guard
            isViewLoaded,
            let userInfo = notification.userInfo,
            let profileImageURL = userInfo["URL"] as? String,
            let url = URL(string: profileImageURL)
        else { return }
        profileImageView?.kf.setImage(with: url)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let avatarURL = ProfileImageService.shared.avatarURL,
           let url = URL(string: avatarURL) {
            profileImageView?.kf.setImage(with: url)
        }
    
        profileImageView = addProfileImageView()
        fullNameLabel = addFullNameLabel()
        emailLabel = addEmailLabel()
        descriptionLabel = addDescriptionLabel()
        addExitButton()
        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile: profile)
        } else {
            print("Profile information is empty")
        }
    }
    
    private func addProfileImageView() -> UIImageView? {
        let imageView = UIImageView(image: UIImage(named: "TestUserPhoto"))
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
        fullNameLabel.text = "Екатерина Новикова"
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
        emailLabel.text = "@ekaterina_nov"
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
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.textColor = UIColor(named: "YPWhite")
        descriptionLabel.font = UIFont(name: "SF Pro Regular", size: 13)
        if let emailLabel = emailLabel {
            descriptionLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8).isActive = true
            descriptionLabel.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor).isActive = true
        }
        return descriptionLabel
    }
    
    private func updateProfileDetails(profile: Profile) {
        
        self.fullNameLabel?.text = profile.name
        self.emailLabel?.text = profile.loginName
        self.descriptionLabel?.text = profile.bio
    }
    
    @IBAction private func exitButtonTapped() {}
}
