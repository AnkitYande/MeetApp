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
    case friendView
    case groupView
}

class SocialViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segCtrl: UISegmentedControl!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let cellIdentifier = "cellIdentifier"
    let storage = Storage.storage()
    
    var userViewModel = UserViewModel()
    var selectionEnabled = false
    var viewMode = SocialViewMode.friendView
    var delegate = CreateEventView()
    
    var filteredUsers: [User] = []
    var selectedUsers: Set<User> = []
    var searchActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed)), animated: false)
        
        if selectionEnabled {
            confirmButton.isHidden = false
            confirmButton.isEnabled = false
        } else {
            confirmButton.isHidden = true
        }
        userViewModel.getAllUsers(excludesSelf: true) { users in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // helper function to reload table but preserve selections
    private func refreshAndPreserveSelections() {
        self.tableView.reloadData()
        for row in 0..<self.tableView.numberOfRows(inSection: 0) {
            let profileCell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as! ProfileCell
            if self.selectedUsers.contains(profileCell.userObject) {
                self.tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            searchActive = false
            refreshAndPreserveSelections()
            return
        }
        
        self.filteredUsers = userViewModel.users.filter({ (user) -> Bool in
            return user.displayName.localizedStandardContains(searchText) || user.username.localizedStandardContains(searchText) || self.selectedUsers.contains(user)
        })
        searchActive = true
        refreshAndPreserveSelections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filteredUsers.count
        }
        return userViewModel.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ProfileCell
        let row = indexPath.row
        
        if searchActive {
            self.storage.reference(forURL: filteredUsers[row].profilePic).getData(maxSize: 1 * 1024 * 1024, completion: { data, error in
                if let error = error {
                    print("PICTURE ERROR: \(error.localizedDescription)")
                } else {
                    let image = UIImage(data: data!)
                    cell.profilePic.image = image
                }
            })
            cell.displayName.text = filteredUsers[row].displayName
            cell.userObject = filteredUsers[row]
        } else {
            self.storage.reference(forURL: userViewModel.users[row].profilePic).getData(maxSize: 1 * 1024 * 1024, completion: { data, error in
                if let error = error {
                    print("PICTURE ERROR: \(error.localizedDescription)")
                } else {
                    let image = UIImage(data: data!)
                    cell.profilePic.image = image
                }
            })
            cell.displayName.text = userViewModel.users[row].displayName
            cell.userObject = userViewModel.users[row]
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectionEnabled {
            if searchActive {
                selectedUsers.insert(filteredUsers[indexPath.row])
            } else {
                selectedUsers.insert(userViewModel.users[indexPath.row])
            }
            
            confirmButton.isEnabled = true
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if selectionEnabled {
            if searchActive {
                selectedUsers.remove(filteredUsers[indexPath.row])
            } else {
                selectedUsers.remove(userViewModel.users[indexPath.row])
            }
            
            let numSelected = tableView.indexPathsForSelectedRows?.count
            if numSelected == nil {
                confirmButton.isEnabled = false
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddSocialSegue" {
            let dest = segue.destination as! AddSocialViewController
            dest.delegate = self
            dest.viewMode = self.viewMode
        }
    }
    
    @objc func addButtonPressed() {
        performSegue(withIdentifier: "AddSocialSegue", sender: self)
    }
    
    @IBAction func segCtrlChanged(_ sender: Any) {
        switch self.segCtrl.selectedSegmentIndex {
        case 0:
            self.viewMode = .friendView
        case 1:
            self.viewMode = .groupView
        default:
            break
        }
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        self.delegate.updateFriendsInvited(newFriends: Array(selectedUsers))
        self.navigationController?.popViewController(animated: true)
    }
}

class ProfileCell: UITableViewCell {
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var displayName: UILabel!
    var userObject: User!
    
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
