//
//  GuestList.swift
//  MeetApp
//
//  Created by Ankit Yande on 11/18/22.
//

import SwiftUI
import FirebaseDatabase
import FirebaseStorage

struct GuestList: View {
    
    let userList:[String]
    @State var users:[User] = []
    @State var usersProfilePictures:[UIImage] = []

    var body: some View {
        List {
            ForEach(Array(users.enumerated()), id:\.offset) { index, user in
                Text(user.displayName)
                Image(uiImage: usersProfilePictures[index])
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
                
                let imageRef = Storage.storage().reference(forURL: profilePic)
                imageRef.getData(maxSize: 1 * 1024 * 1024, completion: { data, error in
                    guard error == nil else {
                        print(error!.localizedDescription)
                        return;
                    }
                    let image = self.resizeImage(image: UIImage(data: data!)!, newWidth: 50, newHeight: 50)
                    
                    self.users.append(newUser)
                    self.usersProfilePictures.append(image)
                    
                })
            })
        }
    }
    
    private func resizeImage(image: UIImage, newWidth: CGFloat, newHeight: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        //let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

struct GuestList_Previews: PreviewProvider {
    static var previews: some View {
        GuestList(userList: [user_id])
    }
}
