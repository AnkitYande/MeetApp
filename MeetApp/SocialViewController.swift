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

enum SocialViewMode {
    case standardView
    case selectView
}

class SocialViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segCtrl: UISegmentedControl!
    @IBOutlet weak var confirmButton: UIButton!
    
    let storage = Storage.storage()
    let cellIdentifier = "cellIdentifier"
    var userViewModel = UserViewModel()
    var users: [User] = [User]()
    var viewMode = SocialViewMode.standardView
    var delegate = CreateEventView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if viewMode == .standardView {
            confirmButton.isHidden = true
        } else if viewMode == .selectView {
            confirmButton.isHidden = false
            confirmButton.isEnabled = false
        }
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
        if viewMode == .standardView {
            tableView.deselectRow(at: indexPath, animated: true)
        } else if viewMode == .selectView {
            confirmButton.isEnabled = true
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let numSelected = tableView.indexPathsForSelectedRows?.count
        if numSelected == nil {
            confirmButton.isEnabled = false
        }
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        guard tableView.indexPathsForSelectedRows != nil else {return}
        
        var friendsInvited = [User]()
        for indexPath in tableView.indexPathsForSelectedRows! {
            friendsInvited.append(userViewModel.users[indexPath.row])
        }
        self.delegate.updateFriendsInvited(newFriends: friendsInvited)
        self.navigationController?.popViewController(animated: true)
    }
}

class ProfileCell: UITableViewCell {
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var displayName: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none
    }
    
}
