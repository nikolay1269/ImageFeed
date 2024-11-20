//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Nikolay on 14.11.2024.
//

import Foundation

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func logout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?
    
    init(view: ProfileViewControllerProtocol? = nil) {
        self.view = view
        addObserver()
    }
    
    func viewDidLoad() {
        guard let profile = ProfileService.shared.profile else { return }
        view?.updateProfileDetails(name: profile.name, email: profile.loginName, bio: profile.bio)
        guard let url = avatarURL() else { return }
        view?.loadImageProfile(url: url)
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector:
                                                    #selector(updateAvatar(notification:)),
                                                 name: ProfileImageService.didChangeNotification,
                                                 object: nil)
    }
    
    @objc
    private func updateAvatar(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let profileImageURL = userInfo["URL"] as? String,
            let url = URL(string: profileImageURL)
        else { return }
        view?.loadImageProfile(url: url)
    }
    
    private func avatarURL() -> URL? {
        guard let avatarURL = ProfileImageService.shared.avatarURL, let url = URL(string: avatarURL) else {
            return nil
        }
        return url
    }
    
    func logout() {
        ProfileLogoutService.shared.logout()
    }
}
