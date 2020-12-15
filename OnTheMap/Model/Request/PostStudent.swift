//
//  PostStudent.swift
//  OnTheMap
//
//  Created by Giovanni Luidi Bruno on 18/11/20.
//  Copyright © 2020 Giovanni Luigi Bruno. All rights reserved.
//

import Foundation


struct PostStudent: Codable {
    
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    
    
}
