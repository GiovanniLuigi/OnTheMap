//
//  OnMapTabBarController.swift
//  OnTheMap
//
//  Created by Giovanni Luidi Bruno on 24/11/20.
//  Copyright © 2020 Giovanni Luigi Bruno. All rights reserved.
//

import UIKit



class OnMapTabBarController: UITabBarController {
    
    private var dataManager: DataManager {
        return DataManager.shared
    }
    
    private var refreshButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    
    // MARK: - Private functions
    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        navigationItem.hidesBackButton = true
        navigationItem.title = "On the Map"
        let refreshButton = UIBarButtonItem(image: UIImage(named: "icon_refresh"), style: .plain, target: self, action: #selector(refresh))
        self.refreshButton = refreshButton
        let addButton = UIBarButtonItem(image: UIImage(named: "icon_addpin"), style: .plain, target: self, action: #selector(add))
        
        self.navigationItem.setRightBarButtonItems([addButton, refreshButton], animated: false)
        
        let logoutButton = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logout))
        self.navigationItem.setLeftBarButton(logoutButton, animated: false)
    }
    
    @objc private func refresh() {
        self.refreshButton?.isEnabled = false
        dataManager.refreshStudents { [weak self] (success) in
            self?.refreshButton?.isEnabled = true
            if !success {
                self?.showAlert(title: "Error", message: "Not able to load students.")
            }
        }
    }
    
    @objc private func add() {
        if let storyboard = storyboard, let vc = initFromStoryboard(type: AddLocationViewController.self, storyboard: storyboard) {
            navigationController?.show(vc, sender: self)
        }
    }
    
    @objc private func logout() {
        let loadingView = addLoadingView()
        Client.logout { [weak self] (result) in
            loadingView.removeFromSuperview()
            switch result {
            case .success:
                if let storyboard = self?.storyboard, let vc = self?.initFromStoryboard(type: LoginViewController.self, storyboard: storyboard) {
                    self?.navigationController?.setViewControllers([vc], animated: false)
                }
            case .failure(let error):
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
}
