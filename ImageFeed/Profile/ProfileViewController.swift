//
//  PfofileViewController.swift
//  ImageFeed
//
//  Created by Nikolay on 18.07.2024.
//

import UIKit

class ProfileViewController: UIViewController {
    
    private var profileImageView: UIImageView?
    private var fullNameLabel: UILabel?
    private var emailLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()

        profileImageView = addImageView()
        fullNameLabel = addFullNameLabel()
        emailLabel = addEmailLabel()
        addDescriptionLabel()
        addExitButton()
    }
    
    private func addImageView() -> UIImageView {
        
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
    
    private func addFullNameLabel() -> UILabel {
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

    private func addEmailLabel() -> UILabel {
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
    
    private func addDescriptionLabel() {
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
    }
    
    @IBAction private func exitButtonTapped() {}
}
