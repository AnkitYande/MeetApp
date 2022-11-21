//
//  EventViewModel.swift
//  MeetApp
//
//  Created by Bo Deng on 11/6/22.
//

import Foundation
import FirebaseDatabase

class GroupObject {

    var groupName: String
    var groupMembersUUID: [String]
    
    init(groupName: String, groupMembersUUID: [String]) {
        self.groupName = groupName
        self.groupMembersUUID = groupMembersUUID
    }
}

final class GroupViewModel: ObservableObject {
    @Published var groups: [GroupObject] = []
    
    var userUUID: String
    
    init(userUUID: String) {
        self.userUUID = userUUID
    }
    
    func createGroup(newGroup: GroupObject) {
        print("creating group")
        
        let newGroupUUID = UUID().uuidString
        var newGroupMembersDict = [String: Bool]()
        for groupMember in newGroup.groupMembersUUID {
            newGroupMembersDict[groupMember] = true
        }
        
        let databaseRef = Database.database().reference()
        databaseRef.child("users").child(userUUID).child("groups").child(newGroupUUID).setValue([
            "groupName": newGroup.groupName,
            "members": newGroupMembersDict
        ])
    }
    
    func getGroups() {
        print("fetching groups")
        self.groups = []

        let databaseRef = Database.database().reference()
        
        databaseRef.child("users").child(userUUID).child("groups").getData(completion: { error, snapshot in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            let groupsOfUser = snapshot?.value as? [String: Any] ?? [String: Any]()
            for (groupUUID, _) in groupsOfUser {
                databaseRef.child("groups").child(groupUUID).getData(completion: { error, snapshot in
                    guard error == nil else {
                        print(error!.localizedDescription)
                        return
                    }
                    let groupDict = snapshot?.value as? [String: Any] ?? [String: Any]()
                    
                    let groupName = groupDict["groupName"] as? String ?? "undefined"
                    let groupMembers = groupDict["members"] as? [String: Any] ?? [String: Any]()
                    
                    let newGroup = GroupObject(groupName: groupName, groupMembersUUID: Array(groupMembers.keys))
                    self.groups.append(newGroup)
                })
            }
        })
    }
}
