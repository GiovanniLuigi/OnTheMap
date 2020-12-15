//
//  DataManager.swift
//  OnTheMap
//
//  Created by Giovanni Luidi Bruno on 01/12/20.
//  Copyright © 2020 Giovanni Luigi Bruno. All rights reserved.
//

import Foundation


protocol DataManagerDelegate {
    func didFetchStudents()
}

class DataManager {
    
    static let shared = DataManager()
    
    private var current: Int = 0
    
    private var studentsLocation = [StudentLocation]()
    
    private var delegates: [DataManagerDelegate] = []
    
    var students: [StudentLocation] {
        return studentsLocation
    }
    
    private init() {}
    
    func addDelegate(_ delegate: DataManagerDelegate) {
        delegates.append(delegate)
    }
    
    func fetchNextStudents(completion: @escaping (_ success: Bool)->Void) {
        Client.fetchStudentLocation(limit: 100, skip: current) { [weak self] (result) in
            switch result {
            case .success(let students):
                self?.studentsLocation = students
                self?.current += 100
                completion(true)
                self?.delegates.forEach({ (delegate) in
                    delegate.didFetchStudents()
                })
            case .failure:
                completion(false)
            }
        }
    }
    
}
