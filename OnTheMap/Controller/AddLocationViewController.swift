//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Giovanni Luidi Bruno on 15/12/20.
//  Copyright © 2020 Giovanni Luigi Bruno. All rights reserved.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController {
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK:- Private functions
    private func setupUI() {
        findLocationButton.layer.cornerRadius = 5
        title = "Add Location"
        
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancel)), animated: true)
    }
    
    @objc private func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    private func didFoundLocation(_ location: CLLocation, region: MKCoordinateRegion, name: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = name
        
        if let vc = storyboard?.instantiateViewController(identifier: "finishAddLocation") as? FinishAddLocationViewController {
            vc.name = name
            vc.location = location
            vc.region = region
            vc.url = urlTextField.text
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    // MARK:- Actions
    @IBAction func findLocation(_ sender: Any) {
        guard let urlText = urlTextField.text, !urlText.isEmpty else {
            showAlert(title: "Error", message: "URL field must be filled")
            return
        }
        
        guard let locationText = locationTextField.text, !locationText.isEmpty else {
            showAlert(title: "Error", message: "Location field must be filled")
            return
        }
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = locationText
        
        let loadingView = addLoadingView()
        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] response, error in
            loadingView.removeFromSuperview()
            guard error == nil, let response = response, let location = response.mapItems.first?.placemark.location, let name = response.mapItems.first?.name else {
                self?.showAlert(title: "Error", message: "Unable to find your location")
                return
            }
            
            self?.didFoundLocation(location, region: response.boundingRegion, name: name)
        }
    }
}
