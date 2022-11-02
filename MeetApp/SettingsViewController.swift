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
        print("User ID: \(user_id)")
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
                     let image = self.resizeImage(image: UIImage(data: data!)!, newWidth: 90, newHeight: 90)
                     self.profilePictureButton.setImage(image, for: .normal)
             }})
          })
        
    }
    @IBAction func buttonPressed(_ sender: Any) {
        let data = Data()
        ImagePickerManager().pickImage(self){ image in
            let newImage = self.resizeImage(image: image, newWidth: 90, newHeight: 90)
            self.profilePictureButton.setImage(newImage, for: .normal)
            let imageRef = self.storage.reference().child("\(user_id).jpg")
            let uploadTask = imageRef.putData(newImage.pngData()!, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    return
                }
                let size = metadata.size
                imageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        return
                    }
                    self.database.child("users").child(user_id).child("profilePic").setValue(downloadURL.absoluteString)
                }
            }
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
