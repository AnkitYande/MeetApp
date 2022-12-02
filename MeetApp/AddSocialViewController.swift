//
//  AddSocialViewController.swift
//  MeetApp
//
//  Created by Bo Deng on 12/1/22.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage


class AddSocialViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var confirmButton: UIButton!
    
    let cellIdentifier = "cellIdentifier"
    let storage = Storage.storage()
    
    var delegate: SocialViewController!
    var userViewModel = UserViewModel()
    var viewMode: SocialViewMode!
    
    var filteredUsers: [User] = []
    var selectedUsers: Set<User> = []
    var searchActive = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        confirmButton.isEnabled = false
        
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if viewMode == .friendView {
            titleLabel.text = "Add Friend"
        } else if viewMode == .groupView {
            titleLabel.text = "Add Group"
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

        if searchActive {
            selectedUsers.insert(filteredUsers[indexPath.row])
        } else {
            selectedUsers.insert(userViewModel.users[indexPath.row])
        }
        confirmButton.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
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
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
