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
    private var isProfileDataLoaded = false
    var presenter: ProfilePresenterProtocol?
    var animationLayers = Set<CALayer>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        profileImageView = addProfileImageView()
        fullNameLabel = addFullNameLabel()
        emailLabel = addEmailLabel()
        descriptionLabel = addDescriptionLabel()
        addLogoutButton()
        view.backgroundColor = UIColor(red: 26.0 / 255.0, green: 27.0 / 255.0, blue: 34.0 / 255.0, alpha: 1.0)
        presenter?.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isProfileDataLoaded == false {
            addGradient(for: profileImageView)
            addGradient(for: fullNameLabel)
            addGradient(for: emailLabel)
            addGradient(for: descriptionLabel)
        }
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
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        imageView.tag = 1
        return imageView
    }
    
    private func addFullNameLabel() -> UILabel? {
        let fullNameLabel = UILabel()
        fullNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fullNameLabel)
        fullNameLabel.textColor = UIColor(named: "YPWhite")
        fullNameLabel.font = UIFont(name: "SF Pro Bold", size: 23)
        fullNameLabel.setTextSpacingBy(value: -0.08)
        fullNameLabel.text = "Ivan Ivanov"
        fullNameLabel.tag = 2
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
        emailLabel.text = "invanov@yandex.ru"
        emailLabel.tag = 3
        if let fullNameLabel = fullNameLabel {
            emailLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 8).isActive = true
            emailLabel.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor).isActive = true
        }
        return emailLabel
    }
    
    private func addLogoutButton() {
        let exitButton = UIButton.systemButton(with: UIImage(named: "Exit") ?? UIImage(), target: self, action: #selector(logoutButtonTapped))
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
        descriptionLabel.text = "some information about person"
        descriptionLabel.tag = 4
        if let emailLabel = emailLabel {
            descriptionLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8).isActive = true
            descriptionLabel.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor).isActive = true
        }
        return descriptionLabel
    }
    
    func updateProfileDetails(name: String, email: String, bio: String) {
        
        isProfileDataLoaded = true
        self.fullNameLabel?.text = name
        self.emailLabel?.text = email
        self.descriptionLabel?.text = bio
        removeGradients()
    }
    
    @IBAction private func logoutButtonTapped() {
        
        let alert = UIAlertController(title: "Выход из профиля",
                                      message: "Вы уверены, что хотите выйти?",
                                      preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] action in
            guard let self = self else { return}
            self.presenter?.logout()
            self.switchToAuthScreen()
        }
        let noAction = UIAlertAction(title: "Нет", style: .default)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true)
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
    
    private func addGradient(for view: UIView?) {
        
        guard let view = view, view.bounds.size != CGSize.zero else { return }
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: view.bounds.size.width, height: view.bounds.size.height))
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.533, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = view.bounds.size.height / 2
        gradient.masksToBounds = true
        animationLayers.insert(gradient)
        view.layer.addSublayer(gradient)
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1.0]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange\(view.tag)")
    }
    
    private func removeGradients() {
        for layer in animationLayers {
            layer.removeFromSuperlayer()
        }
        animationLayers.removeAll()
    }
}
