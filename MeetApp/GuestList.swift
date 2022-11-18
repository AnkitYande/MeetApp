//
//  GuestList.swift
//  MeetApp
//
//  Created by Ankit Yande on 11/18/22.
//

import SwiftUI
import FirebaseDatabase

struct GuestList: View {
    
    let userList:[String]
    @State var users:[User] = []

    var body: some View {
        List {
            ForEach(users, id:\.UID) { user in
                Text(user.displayName)
            }
        }
        .refreshable {
            self.loadUsers()
        }
        .onAppear {
            self.loadUsers()
        }
    }
    
    func loadUsers(){
        self.users = []
        let databaseRef = Database.database().reference()
        for userID in userList {
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
                let newUser = User(UID: userID, email: email, displayName: displayName, username: username, profilePic: profilePic, status: status, latitude: latitude, longitude: longitude, eventsInvited: [], eventsHosting: [])
                self.users.append(newUser)
            })
        }
    }
}

struct GuestList_Previews: PreviewProvider {
    static var previews: some View {
        GuestList(userList: [user_id])
    }
}
