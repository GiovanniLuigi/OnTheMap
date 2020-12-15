//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Giovanni Luidi Bruno on 11/12/20.
//  Copyright © 2020 Giovanni Luigi Bruno. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var dataManager: DataManager {
        return DataManager.shared
    }
    
    private let cellIdentifier = "studentLocationCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupDataManager()
    }
    
    // MARK:- Private functions
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func setupDataManager() {
        dataManager.addDelegate(self)
    }
}


// MARK:- UITableViewDataSource
extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? StudentLocationTableViewCell {
            let student = dataManager.students[indexPath.row]
            cell.fullNameLabel.text = student.fullName
            cell.mediaUrlLabel.text = student.mediaURL
            
            return cell
        }
        
        return UITableViewCell()
    }
    
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let student = dataManager.students[indexPath.row]
        if let url = URL(string: student.mediaURL) {
            Client.openURL(url: url)
        }
    }
}


// MARK:- DataManagerDelegate
extension ListViewController: DataManagerDelegate {
    func didFetchStudents() {
        tableView.reloadData()
    }
}
