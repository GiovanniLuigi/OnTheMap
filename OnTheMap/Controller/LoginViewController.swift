//
//  ViewController.swift
//  OnTheMap
//
//  Created by Giovanni Luidi Bruno on 17/11/20.
//  Copyright © 2020 Giovanni Luigi Bruno. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK:- Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var fbLoginButton: UIButton!
    
    
    // MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        setupTextFields()
        setupKeyboard()
        setupNavigationBar()
    }
    
    
    // MARK:- Private functions
    private func setupButtons() {
        loginButton.layer.cornerRadius = 5
        fbLoginButton.layer.cornerRadius = 5
    }
    
    private func setupTextFields() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func setupKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK:- Actions
    @IBAction func login(_ sender: Any) {
        guard let username = emailTextField.text, let password = passwordTextField.text, !username.isEmpty, !password.isEmpty else {
            showAlert(title: "Error to Login", message: "Email and password fields must be filled")
            return
        }
        
        let loadingView = addLoadingView()
        Client.login(loginRequest: LoginRequest(udacity: UserCredentials(username: username, password: password))) { [weak self] (result)  in
            loadingView.removeFromSuperview()
            switch result {
            case .success:
                if let storyboard = self?.storyboard, let vc = self?.initFromStoryboard(type: OnMapTabBarController.self, storyboard: storyboard) {
                    self?.navigationController?.setViewControllers([vc], animated: true)
                }
            case .failure(let error):
                self?.showAlert(title: "Error to Login", message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func fbLogin(_ sender: Any) {
    }
    
    @IBAction func signUp(_ sender: Any) {
        Client.signup()
    }
}


// MARK:- UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.endEditing(true)
            login(self)
        }
        
        return true
    }
}
