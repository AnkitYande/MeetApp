//
//  UserViewModel.swift
//  MeetApp
//
//  Created by Lorenzo Martinez on 11/8/22.
//

import Foundation
import FirebaseDatabase
import UIKit

final class UserViewModel: ObservableObject {
    
    @Published var users: [User] = []
    
    func generateUser(userID: String, userInfo: [String: Any]) -> User {
        let username = userInfo["username"] as! String
        let email = userInfo["email"] as! String
        let displayName = userInfo["displayName"] as! String
        let profilePic = userInfo["profilePic"] as! String
        let status = userInfo["status"] as! String
        let latitude = userInfo["latitude"] as! Double
        let longitude = userInfo["longitude"] as! Double
        
        var allEvents = [String]()
        var hostEvents = [String]()
        if let eventsInvited = userInfo["eventsInvited"] as? [String: Any] {
            for (eventUUID, _) in eventsInvited {
                allEvents.append(eventUUID)
            }
        }
        if let eventsHosting = userInfo["eventsHosting"] as? [String: Any] {
            for (eventUUID, _) in eventsHosting {
                allEvents.append(eventUUID)
                hostEvents.append(eventUUID)
            }
        }
        
        let newUser = User(UID: userID, email: email, displayName: displayName, username: username, profilePic: profilePic, status: status, latitude: latitude, longitude: longitude, eventsInvited: allEvents, eventsHosting: hostEvents)
        
        return newUser
    }
    
    func getAllUsers(excludesSelf: Bool, completion: @escaping ([User]) -> Void) {
        print("Fetching all users...")
        let group = DispatchGroup()
        group.enter()
        
        self.users = []
        let databaseRef = Database.database().reference()
        
        DispatchQueue.main.async {
            databaseRef.child("users").getData(completion: { error, snapshot in
                guard error == nil else {
                    print("ERROR: \(error!.localizedDescription)")
                    completion(self.users)
                    return;
                }
                let allUsers = snapshot?.value as? [String: Any] ?? [String: Any]();
                var count = 0
                for (userID, _) in allUsers {
                    if excludesSelf && userID == user_id {
                        continue
                    }
                    databaseRef.child("users").child(userID).getData(completion: { error, snapshot in
                        guard error == nil else {
                            print("ERROR: \(error!.localizedDescription)")
                            completion(self.users)
                            return;
                        }
                        let userInfo = snapshot?.value as? [String: Any] ?? [String: Any]();
                        let username = userInfo["username"] as! String
                        let email = userInfo["email"] as! String
                        let displayName = userInfo["displayName"] as! String
                        let profilePic = userInfo["profilePic"] as! String
                        let status = userInfo["status"] as! String
                        let latitude = userInfo["latitude"] as! Double
                        let longitude = userInfo["longitude"] as! Double
                        
                        var allEvents = [String]()
                        var hostEvents = [String]()
                        if let eventsInvited = userInfo["eventsInvited"] as? [String: Any] {
                            for (eventUUID, _) in eventsInvited {
                                allEvents.append(eventUUID)
                            }
                        }
                        if let eventsHosting = userInfo["eventsHosting"] as? [String: Any] {
                            for (eventUUID, _) in eventsHosting {
                                allEvents.append(eventUUID)
                                hostEvents.append(eventUUID)
                            }
                        }
                        
                        let newUser = User(UID: userID, email: email, displayName: displayName, username: username, profilePic: profilePic, status: status, latitude: latitude, longitude: longitude, eventsInvited: allEvents, eventsHosting: hostEvents)
                        self.users.append(newUser)
                        count += 1
                        if excludesSelf && count == allUsers.count - 1 {
                            group.leave()
                        } else if !excludesSelf && count == allUsers.count {
                            group.leave()
                        }
                    })
                }
            })
        }
        
        group.notify(queue: .main) {
            self.users.sort(by: { $0.displayName < $1.displayName })
            print("Finished retrieving all users. Total count: \(self.users.count)")
            completion(self.users)
        }
    }
    
    func getFriends(completion: @escaping ([User]) -> Void) {
        print("Fetching all friends for \(user_id)...")
        let group = DispatchGroup()
        group.enter()
        
        self.users = []
        let databaseRef = Database.database().reference()
        
        DispatchQueue.main.async {
            databaseRef.child("users").child(user_id).child("friends").getData(completion: { error, snapshot in
                guard error == nil else {
                    print("ERROR: \(error!.localizedDescription)")
                    completion(self.users)
                    return;
                }
                
                let allFriends = snapshot?.value as? [String: Any] ?? [String: Any]();
                var count = 0
                
                for (userID, _) in allFriends {
                    databaseRef.child("users").child(userID).getData(completion: { error, snapshot in
                        guard error == nil else {
                            print("ERROR: \(error!.localizedDescription)")
                            completion(self.users)
                            return;
                        }
                        let userInfo = snapshot?.value as? [String: Any] ?? [String: Any]();
                        let username = userInfo["username"] as! String
                        let email = userInfo["email"] as! String
                        let displayName = userInfo["displayName"] as! String
                        let profilePic = userInfo["profilePic"] as! String
                        let status = userInfo["status"] as! String
                        let latitude = userInfo["latitude"] as! Double
                        let longitude = userInfo["longitude"] as! Double
                        
                        var allEvents = [String]()
                        var hostEvents = [String]()
                        if let eventsInvited = userInfo["eventsInvited"] as? [String: Any] {
                            for (eventUUID, _) in eventsInvited {
                                allEvents.append(eventUUID)
                            }
                        }
                        if let eventsHosting = userInfo["eventsHosting"] as? [String: Any] {
                            for (eventUUID, _) in eventsHosting {
                                allEvents.append(eventUUID)
                                hostEvents.append(eventUUID)
                            }
                        }
                        
                        let newUser = User(UID: userID, email: email, displayName: displayName, username: username, profilePic: profilePic, status: status, latitude: latitude, longitude: longitude, eventsInvited: allEvents, eventsHosting: hostEvents)
                        self.users.append(newUser)
                        count += 1
                        if count == allFriends.count {
                            group.leave()
                        }
                    })
                }
            })
        }
        
        group.notify(queue: .main) {
            self.users.sort(by: { $0.displayName < $1.displayName })
            print("Finished retrieving all friends. Total count: \(self.users.count)")
            completion(self.users)
        }
    }
}
