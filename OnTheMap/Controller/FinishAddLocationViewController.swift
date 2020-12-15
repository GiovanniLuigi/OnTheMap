//
//  FinishAddLocationViewController.swift
//  OnTheMap
//
//  Created by Giovanni Luidi Bruno on 15/12/20.
//  Copyright © 2020 Giovanni Luigi Bruno. All rights reserved.
//

import UIKit
import MapKit

class FinishAddLocationViewController: UIViewController {
    
    // MARK:- Properties
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var location: CLLocation?
    var region: MKCoordinateRegion?
    var name: String?
    var url: String?
    
    // MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configMap()
    }
    
    // MARK:- Private functions
    private func setupUI() {
        finishButton.layer.cornerRadius = 5
        title = "Add Location"
    }
    
    private func configMap() {
        mapView.removeAnnotations(mapView.annotations)
        
        guard let location = self.location, let region = self.region, let name = self.name else {
            return
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = name
        mapView.addAnnotation(annotation)
        
        mapView.setRegion(region, animated: true)
    }
    
    // MARK:- Actions
    @IBAction func finish(_ sender: Any) {
        guard let user = Client.Auth.user, let location = self.location, let name = self.name, let urlString = url else {
            return
        }
        let request = PostStudent(uniqueKey: UUID().uuidString, firstName: user.firstName, lastName: user.lastName, mapString: name, mediaURL: urlString, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        Client.postStudentLocation(postStudent: request) { [weak self] (result) in
            switch result {
            case .success:
                self?.navigationController?.popToRootViewController(animated: true)
            case .failure(let error):
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
}
