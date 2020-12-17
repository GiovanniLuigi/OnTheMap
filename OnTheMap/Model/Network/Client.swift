//
//  Client.swift
//  OnTheMap
//
//  Created by Giovanni Luidi Bruno on 17/11/20.
//  Copyright © 2020 Giovanni Luigi Bruno. All rights reserved.
//

import Foundation
import UIKit

struct Client {
    
    static let timeout: TimeInterval = 60
    
    struct Auth {
        static var user: UserResponse? = nil
    }
    
    enum ClientError: Error, LocalizedError {
        case parsingError
        case invalidCredentials
        
        var errorDescription: String? {
            switch self {
            case .parsingError:
                return "Invalid data. Parsing error."
            case .invalidCredentials:
                return "Account not found or invalid credentials."
            }
        }
    }
    
    enum HttpMethod: String {
        case GET, POST, PUT, DELETE
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case studentLocation
        case putStudentLocation(String)
        case session
        case signup
        case user(String)
        
        var stringValue: String {
            switch self {
            case .studentLocation:
                return Endpoints.base + "/StudentLocation"
            case .putStudentLocation(let id):
                return Endpoints.base + "/StudentLocation/\(id)"
            case .session:
                return Endpoints.base + "/session"
            case .signup:
                return "https://auth.udacity.com/sign-up"
            case .user(let id):
                return Endpoints.base + "/users/\(id)"
            }
        }
        
        var url: URL {
            return URL(string: self.stringValue)!
        }
        
        var urlComponents: URLComponents {
            return URLComponents(string: self.stringValue)!
        }
    }
    
    static func openURL(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    static func signup() {
        UIApplication.shared.open(Endpoints.signup.url, options: [:], completionHandler: nil)
    }
    
    static func login(loginRequest: LoginRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let body = try? JSONEncoder().encode(loginRequest) else {
            completion(.failure(ClientError.parsingError))
            return
        }
        
        var request = URLRequest(url: Endpoints.session.url, timeoutInterval: timeout)
        request.httpMethod = HttpMethod.POST.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        doHttpRequest(request, modelType: LoginResponse.self, skip: 5) { (result) in
            switch result {
            case .success(let response):
                user(id: response.session.id) { (result) in
                    switch result {
                        
                    case .success(let user):
                        Auth.user = user
                        completion(.success(true))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func user(id: String, completion: @escaping (Result<UserResponse, Error>) -> Void) {
        var request = URLRequest(url: Endpoints.user(id).url, timeoutInterval: timeout)
        request.httpMethod = HttpMethod.GET.rawValue
        
        doHttpRequest(request, skip: 5) { (result) in
            switch result {
            case .success(let data):
                guard let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String:Any],
                    let firstName = json["first_name"] as? String, let lastName = json["last_name"] as? String else {
                        completion(.failure(ClientError.parsingError))
                        return
                }
                
                let userResponse = UserResponse(firstName: firstName, lastName: lastName)
                completion(.success(userResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
    static func logout(completion: @escaping (Result<Session, Error>) -> Void) {
        var request = URLRequest(url: Endpoints.session.url, timeoutInterval: timeout)
        request.httpMethod = HttpMethod.DELETE.rawValue
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        doHttpRequest(request, modelType: [String: Session].self, skip: 5) { (result) in
            switch result {
            case .success(let response):
                guard let session = response["session"] else {
                    completion(.failure(ClientError.parsingError))
                    return
                }
                completion(.success(session))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func postStudentLocation(postStudent: PostStudent, completion: @escaping (Result<PostStudentResponse, Error>) -> Void) {
        studentLocation(postStudent: postStudent, method: .POST, url: Endpoints.studentLocation.url, completion: completion)
    }
    
    static func putStudentLocation(postStudent: PostStudent, objectId: String, completion: @escaping (Result<PutStudentResponse, Error>) -> Void) {
        studentLocation(postStudent: postStudent, method: HttpMethod.PUT, url: Endpoints.putStudentLocation(objectId).url, completion: completion)
    }
    
    static func studentLocation<R: Codable>(postStudent: PostStudent, method: HttpMethod, url: URL, completion: @escaping (Result<R, Error>) -> Void) {
        guard let data = try? JSONEncoder().encode(postStudent) else {
            completion(.failure(ClientError.parsingError))
            return
        }
        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        
        doHttpRequest(request, modelType: R.self) { (result) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func fetchStudentLocation(limit: Int? = nil, skip: Int? = nil, order: String? = nil, uniqueKey: String? = nil, completion: @escaping (Result<[StudentLocation], Error>) -> Void) {
        var urlComponents = Endpoints.studentLocation.urlComponents
        urlComponents.queryItems = []
        
        if let limit = limit {
            urlComponents.queryItems?.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        
        if let skip = skip {
            urlComponents.queryItems?.append(URLQueryItem(name: "skip", value: String(skip)))
        }
        
        if let order = order {
            urlComponents.queryItems?.append(URLQueryItem(name: "order", value: order))
        }
        
        if let uniqueKey = uniqueKey {
            urlComponents.queryItems?.append(URLQueryItem(name: "uniqueKey", value: uniqueKey))
        }
        
        if let url = urlComponents.url {
            var request = URLRequest(url: url, timeoutInterval: timeout)
            request.httpMethod = HttpMethod.GET.rawValue
            
            doHttpRequest(request, modelType: [String: [StudentLocation]].self) { (result) in
                switch result {
                case .success(let response):
                    if let students = response["results"] {
                        completion(.success(students))
                    } else {
                        completion(.failure(ClientError.parsingError))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func doHttpRequest(_ request: URLRequest, skip: Int? = nil, completion: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard var data = data else {
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                return
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode == 403 {
                DispatchQueue.main.async {
                    completion(.failure(ClientError.invalidCredentials))
                }
                return
            }
            
            if let skip = skip {
                data = data.subdata(in: skip..<data.count)
            }
            
            DispatchQueue.main.async {
                completion(.success(data))
            }
            
        }.resume()
    }
    
    static func doHttpRequest<S: Codable>(_ request: URLRequest, modelType: S.Type, skip: Int? = nil, completion: @escaping (Result<S, Error>) -> Void) {
        doHttpRequest(request, skip: skip) { (result) in
            switch result {
            case .success(let data):
                do {
                    let obj = try JSONDecoder().decode(modelType, from: data)
                    completion(.success(obj))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
