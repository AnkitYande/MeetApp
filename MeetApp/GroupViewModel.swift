//
//  EventViewModel.swift
//  MeetApp
//
//  Created by Bo Deng on 11/6/22.
//

import Foundation
import FirebaseDatabase

class GroupObject: Identifiable, Hashable, CustomStringConvertible {
    var description: String { return "groupUUID: \(self.groupUUID)" }
    
    public static func == (lhs: GroupObject, rhs: GroupObject) -> Bool {
        return lhs.groupUUID == rhs.groupUUID
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(self.groupUUID)
    }

    var groupUUID: String
    var groupName: String
    var groupMembersUUID: [String]
    
    init(groupUUID: String, groupName: String, groupMembersUUID: [String]) {
        self.groupUUID = groupUUID
        self.groupName = groupName
        self.groupMembersUUID = groupMembersUUID
    }
    
    
}

final class GroupViewModel: ObservableObject {
    @Published var groups: [GroupObject] = []
    
    static func createGroup(newGroup: GroupObject) {
        let databaseRef = Database.database().reference()
        
        databaseRef.child("groups").child(newGroup.groupUUID).child("groupName").setValue(newGroup.groupName)
        
        for groupMemberUUID in newGroup.groupMembersUUID {
            databaseRef.child("groups").child(newGroup.groupUUID).child("members").child(groupMemberUUID).setValue(true)
            databaseRef.child("users").child(groupMemberUUID).child("groups").child(newGroup.groupUUID).setValue(true)
        }
    }
    
    static func getUsersInGroups(groups: [GroupObject]) {
        
    }
    
    func getGroups(completion: @escaping ([GroupObject]) -> Void) {
        print("fetching groups")
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        self.groups = []
        let databaseRef = Database.database().reference()
        
        DispatchQueue.main.async {
            
            databaseRef.child("users").child(user_id).child("groups").getData(completion: { error, snapshot in
                guard error == nil else {
                    print(error!.localizedDescription)
                    completion(self.groups)
                    return
                }
                
                let groupsOfUser = snapshot?.value as? [String: Any] ?? [String: Any]()
                var count = 0
                
                for (groupUUID, _) in groupsOfUser {
                    print("groupUUID: \(groupUUID)")
                    databaseRef.child("groups").child(groupUUID).getData(completion: { error, snapshot in
                        guard error == nil else {
                            print(error!.localizedDescription)
                            completion(self.groups)
                            return
                        }
                        let groupDict = snapshot?.value as? [String: Any] ?? [String: Any]()
                        
                        let groupName = groupDict["groupName"] as? String ?? "undefined"
                        let groupMembers = groupDict["members"] as? [String: Any] ?? [String: Any]()
                        
                        let newGroup = GroupObject(groupUUID: groupUUID, groupName: groupName, groupMembersUUID: Array(groupMembers.keys))
                        self.groups.append(newGroup)
                        count += 1
                        if count == groupsOfUser.count {
                            dispatchGroup.leave()
                        }
                    })
                }
            })
        }
        
        dispatchGroup.notify(queue: .main) {
            self.groups.sort(by: { $0.groupName < $1.groupName })
            print("Finished retrieving all groups. Total count: \(self.groups.count)")
            completion(self.groups)
        }
    }
}
