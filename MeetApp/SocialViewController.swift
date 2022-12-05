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
    
    let profileCellIdentifier = "profileCell"
    let groupCellIdentifier = "groupCell"
    let storage = Storage.storage()
    
    var userViewModel = UserViewModel()
    var groupViewModel = GroupViewModel()
    var selectionEnabled = false
    var viewMode = SocialViewMode.friendView
    var delegate = CreateEventView()
    
    var filteredFriends: [User] = []
    var selectedFriends: Set<User> = []
    var filteredGroups: [GroupObject] = []
    var selectedGroups: Set<GroupObject> = []
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
        
        if selectionEnabled {
            confirmButton.isHidden = false
            confirmButton.isEnabled = false
        } else {
            confirmButton.isHidden = true
            
            self.navigationController?.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed)), animated: false)
        }
        switch self.viewMode {
        case .friendView:
            userViewModel.getFriends() { users in
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        case .groupView:
            groupViewModel.getGroups() { groups in
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }

    }
    
    // helper function to reload table but preserve selections
    private func refreshAndPreserveSelections() {
        self.tableView.reloadData()
        for row in 0..<self.tableView.numberOfRows(inSection: 0) {
            switch self.viewMode {
            case .friendView:
                let profileCell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as! ProfileCell
                if self.selectedFriends.contains(profileCell.userObject) {
                    self.tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
                }
            case .groupView:
                let groupCell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as! GroupCell
                if self.selectedGroups.contains(groupCell.groupObject!) {
                    self.tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            searchActive = false
            refreshAndPreserveSelections()
            return
        }
        
        self.filteredFriends = userViewModel.users.filter({ (user) -> Bool in
            return user.displayName.localizedStandardContains(searchText) || user.username.localizedStandardContains(searchText) || self.selectedFriends.contains(user)
        })
        self.filteredGroups = groupViewModel.groups.filter({ (group) -> Bool in
            return group.groupName.localizedStandardContains(searchText) || self.selectedGroups.contains(group)
        })
        
        searchActive = true
        refreshAndPreserveSelections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive && viewMode == .friendView {
            return filteredFriends.count
        }
        if searchActive && viewMode == .groupView {
            return filteredGroups.count
        }
        if !searchActive && viewMode == .friendView {
            return userViewModel.users.count
        }
        return groupViewModel.groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewMode == .friendView {
            let cell = tableView.dequeueReusableCell(withIdentifier: profileCellIdentifier, for: indexPath) as! ProfileCell
            let row = indexPath.row
            
            if searchActive {
                self.storage.reference(forURL: filteredFriends[row].profilePic).getData(maxSize: 1 * 1024 * 1024, completion: { data, error in
                    if let error = error {
                        print("PICTURE ERROR: \(error.localizedDescription)")
                    } else {
                        let image = UIImage(data: data!)
                        cell.profilePic.image = image
                    }
                })
                cell.displayName.text = filteredFriends[row].displayName
                cell.userObject = filteredFriends[row]
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: groupCellIdentifier, for: indexPath) as! GroupCell
        let row = indexPath.row
        
        if searchActive {
            cell.groupName.text = filteredGroups[row].groupName
            cell.groupObject = filteredGroups[row]
        } else {
            cell.groupName.text = groupViewModel.groups[row].groupName
            cell.groupObject = groupViewModel.groups[row]
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectionEnabled {
            switch viewMode {
            case .friendView:
                if searchActive {
                    selectedFriends.insert(filteredFriends[indexPath.row])
                } else {
                    selectedFriends.insert(userViewModel.users[indexPath.row])
                }
            case .groupView:
                if searchActive {
                    selectedGroups.insert(filteredGroups[indexPath.row])
                } else {
                    selectedGroups.insert(groupViewModel.groups[indexPath.row])
                }
                
                // if a group is selected, add all friends contained in the group to selected friends
                for selectedGroup in selectedGroups {
                    let groupMembersUUIDSet = Set(selectedGroup.groupMembersUUID)
                    let friendsContainedInGroup = userViewModel.users.filter { groupMembersUUIDSet.contains($0.UID) }
                    selectedFriends.formUnion(friendsContainedInGroup)
                }
            }
            
            confirmButton.isEnabled = true
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if selectionEnabled {
            switch viewMode {
            case .friendView:
                var friendToRemove: User
                if searchActive {
                    friendToRemove = filteredFriends[indexPath.row]
                } else {
                    friendToRemove = userViewModel.users[indexPath.row]
                }
                selectedFriends.remove(friendToRemove)
                
                // if the friend that is removed is in a selected group, deselect that group
                selectedGroups = selectedGroups.filter { !$0.groupMembersUUID.contains(friendToRemove.UID) }
                
            case .groupView:
                if searchActive {
                    selectedGroups.remove(filteredGroups[indexPath.row])
                } else {
                    selectedGroups.remove(groupViewModel.groups[indexPath.row])
                }
            }
            
            let numSelected = selectedFriends.count + selectedGroups.count
            if numSelected == 0 {
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
        
        switch self.viewMode {
        case .friendView:
            userViewModel.getFriends() { users in
                DispatchQueue.main.async {
                    self.refreshAndPreserveSelections()
                }
            }
        case .groupView:
            groupViewModel.getGroups() { groups in
                DispatchQueue.main.async {
                    print(groups.count)
                    print(self.groupViewModel.groups.count)
                    self.refreshAndPreserveSelections()
                }
            }
        }
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        
        self.delegate.updateFriendsInvited(newFriends: Array(selectedFriends))
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

class GroupCell: UITableViewCell {
    @IBOutlet weak var groupName: UILabel!
    var groupObject: GroupObject!
    
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
