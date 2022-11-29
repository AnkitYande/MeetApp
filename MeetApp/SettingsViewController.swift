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
import Foundation
import CoreData

class SettingsViewController: UIViewController {

    private let database = Database.database().reference()
    private let storage = Storage.storage()
    
    @IBOutlet weak var socialNotificationSwitch: UISwitch!
    @IBOutlet weak var checkInNotificationSwitch: UISwitch!
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePictureButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadImage()
    }
    
    func downloadImage() {
        // TODO: see if can do 1 getData call and get user data
        print("User ID: \(user_id)")
        database.child("users").child(user_id).getData(completion: { error, snapshot in
            guard error == nil else {
              print(error!.localizedDescription)
              return;
            }
            var snap = snapshot?.value as? [String: Any]
            print(snap)
            let image_url = snap?["profilePic"] as? String ?? "Unknown"
            print("image_url: \(image_url)")
            self.displayName.text = snap?["displayName"] as? String
            self.username.text = snap?["username"] as? String
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
    
    @IBAction func checkInNotifSwitch(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let checkInNotif = NSEntityDescription.entity(forEntityName: "notifications", in: context)
        
        if checkInNotificationSwitch.isOn {
            checkInNotif?.setValue(true, forKey: "checkIn")
        } else {
            checkInNotif?.setValue(false, forKey: "checkIn")
        }
        
        appDelegate.saveContext()
    }
    
    @IBAction func socialNotifSwitch(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let checkInNotif = NSEntityDescription.entity(forEntityName: "notifications", in: context)
        
        if checkInNotificationSwitch.isOn {
            checkInNotif?.setValue(true, forKey: "social")
        } else {
            checkInNotif?.setValue(false, forKey: "social")
        }
        
        appDelegate.saveContext()
    }
    
    func retrieveNotifications() -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "notifications")
        var fetchedResults: [NSManagedObject]?

        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }

        return (fetchedResults)!
    }
    
    @IBAction func signOutButtonPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
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
