//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Giovanni Luidi Bruno on 17/11/20.
//  Copyright © 2020 Giovanni Luigi Bruno. All rights reserved.
//

import Foundation


struct StudentLocation: Codable {
    
    let createdAt: String
    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let mapString: String
    let mediaURL: String
    let objectId: String
    let uniqueKey: String
    let updatedAt: String
        
    
    var fullName: String {
        return firstName + " " + lastName
    }
}
