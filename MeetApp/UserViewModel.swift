//
//  UserViewModel.swift
//  MeetApp
//
//  Created by Lorenzo Martinez on 11/8/22.
//

import Foundation
import FirebaseDatabase

final class UserViewModel: ObservableObject {
    
    @Published var users: [User] = []
    
    var userUUID: String
    
    init(userUUID: String) {
        self.userUUID = userUUID
    }
    
    func getAllUsers() {
        self.users = []
        let databaseRef = Database.database().reference()
        
        databaseRef.child("users").getData(completion: { error, snapshot in
            guard error == nil else {
                print(error!.localizedDescription)
                return;
            }
            let allUsers = snapshot?.value as? [String: Any] ?? [String: Any]();
            for (userID, _) in allUsers {
                databaseRef.child("users").child(userID).getData(completion: { error, snapshot in
                    guard error == nil else {
                        print(error!.localizedDescription)
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
                })
            }
        })
    }
}
