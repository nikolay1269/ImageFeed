//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Nikolay on 01.11.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenter(view: profileViewController)
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController
        profileViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "ProfileTabActive"), selectedImage: nil)
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}

