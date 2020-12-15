//
//  UIViewController+Extensions.swift
//  OnTheMap
//
//  Created by Giovanni Luidi Bruno on 24/11/20.
//  Copyright © 2020 Giovanni Luigi Bruno. All rights reserved.
//

import UIKit


extension UIViewController {
    
    func initFromStoryboard<VC>(type: VC.Type, storyboard: UIStoryboard) -> VC? {
        let id = String(describing: type)
        
        if let vc = storyboard.instantiateViewController(withIdentifier: id) as? VC {
            return vc
        }
        
        return nil
    }
    
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func addLoadingView() -> UIView {
        let loadingView = UIView()
        loadingView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        view.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        loadingView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 75, height: 75))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.large
        loadingIndicator.startAnimating()
        loadingIndicator.color = UIColor.white
        
        loadingView.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor).isActive = true
        
        return loadingView
    }
    
}
