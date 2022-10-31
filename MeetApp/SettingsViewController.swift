//
//  SettingsViewController.swift
//  MeetApp
//
//  Created by Ankit Yande on 10/18/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class SettingsViewController: UIViewController {

    private let database = Database.database().reference()
    private let storage = Storage.storage()
    
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePictureButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: Fill in displayName and username here
        displayName.text = "First Last"
        username.text = "username"
        downloadImage()
    }
    
    func downloadImage() {
        // TODO: see if can do 1 getData call and get user data
         database.child("users").child(user_id).child("profilePic").getData(completion: { error, snapshot in
            guard error == nil else {
              print(error!.localizedDescription)
              return;
            }
            let image_url = snapshot?.value as? String ?? "Unknown"
            let storageRef = self.storage.reference(forURL: image_url).getData(maxSize: 1 * 1024 * 1024, completion: { data, error in
                 if let error = error {
                     // TODO: alert user image is not correct size
                     print("picture is above max size")
                 } else {
                     self.profilePictureButton.setImage(UIImage(data: data!), for: .normal)
             }})
          })
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
