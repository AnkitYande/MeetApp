//
//  SocialViewController.swift
//  MeetApp
//
//  Created by Ankit Yande on 10/18/22.
//

import UIKit
import Foundation
import FirebaseDatabase
import FirebaseStorage

class SocialViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segCtrl: UISegmentedControl!
    
    let storage = Storage.storage()
    let cellIdentifier = "cellIdentifier"
    var userViewModel = UserViewModel()
    var users: [User] = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        userViewModel.getAllUsers() { users in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userViewModel.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ProfileCell
        let row = indexPath.row
        
        let storageRef = self.storage.reference(forURL: userViewModel.users[row].profilePic).getData(maxSize: 1 * 1024 * 1024, completion: { data, error in
             if let error = error {
                 print("PICTURE ERROR: \(error.localizedDescription)")
             } else {
                 let image = UIImage(data: data!)
                 cell.profilePic.image = image
                 
         }})
        cell.displayName.text = userViewModel.users[row].displayName
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class ProfileCell: UITableViewCell {
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var displayName: UILabel!
}
