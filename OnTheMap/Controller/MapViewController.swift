//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Giovanni Luidi Bruno on 01/12/20.
//  Copyright © 2020 Giovanni Luigi Bruno. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    private let pinIdentifier = "pin"
    
    private var dataManager: DataManager {
        return DataManager.shared
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupDataManager()
        fetchStudents()
    }
    
    
    // MARK: - Private functions
    private func setupMapView() {
        mapView.delegate = self
    }
    
    private func setupDataManager() {
        dataManager.addDelegate(self)
    }
    
    private func fetchStudents() {
        if dataManager.students.isEmpty {
            dataManager.refreshStudents { (_) in
            }
        } else {
            clearAndUpdateMap()
        }
    }
    
    private func clearAndUpdateMap() {
        mapView.removeAnnotations(mapView.annotations)
        var annotations = [MKAnnotation]()
        self.dataManager.students.forEach { (student) in
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
            annotation.title = student.fullName
            annotation.subtitle = student.mediaURL

            annotations.append(annotation)
        }
        self.mapView.addAnnotations(annotations)
    }
    
    @objc private func openStudentURL(_ sender: UITapGestureRecognizer) {
        if let view = sender.view as? MKAnnotationView, let urlString = view.annotation?.subtitle, let url = URL(string: urlString ?? "") {
            Client.openURL(url: url)
        }
    }
    
}


// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: pinIdentifier) {
            pinView.annotation = annotation
            return pinView
        }
        
        let pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: pinIdentifier)
        pinView.canShowCallout = true
        pinView.image = UIImage(named: "icon_pin")
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(MapViewController.openStudentURL(_:)))
        view.addGestureRecognizer(gesture)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.gestureRecognizers = []
    }
    
}

// MARK:- DataManagerDelegate
extension MapViewController: DataManagerDelegate {
    func didFetchStudents() {
        clearAndUpdateMap()
    }
}
