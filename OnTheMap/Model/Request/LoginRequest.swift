//
//  LoginRequest.swift
//  OnTheMap
//
//  Created by Giovanni Luidi Bruno on 19/11/20.
//  Copyright © 2020 Giovanni Luigi Bruno. All rights reserved.
//

import Foundation

struct LoginRequest: Codable {
    let udacity: UserCredentials
}

struct UserCredentials: Codable {
    let username: String
    let password: String
}
