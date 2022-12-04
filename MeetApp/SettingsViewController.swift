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
    
    @IBOutlet weak var checkInNotificationSwitch: UISwitch!
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePictureButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadImage()
        self.checkInNotificationSwitch.addTarget(self, action: #selector(onSwitchValueChanged(_:)), for: .valueChanged)
        checkSwitchPosition()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkSwitchPosition()
    }
    
    // downlaods image from firebase storage and makes it appear on the settings screen
    func downloadImage() {
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
    
    //checks to see if user wants to change their profile picture by clicking on the image button
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
    
    // checks to see what the checkIn notification is set to in core data and sets the switch respectively
    private func checkSwitchPosition() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Notifications")
        
        var fetchedResults: [NSManagedObject]?

        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
            
            let notification = fetchedResults?.first
            
            var notificationVal = notification?.value(forKey: "checkIn") as! Int
            
            if notificationVal == 1 {
                print("entered on")
                checkInNotificationSwitch.setOn(true, animated: false)
            } else {
                print("entered off")
                checkInNotificationSwitch.setOn(false, animated: false)
            }
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    //a listener to see if user flips switch
    @objc private func onSwitchValueChanged(_ sender: UISwitch) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Notifications")
        
        var fetchedResults: [NSManagedObject]?
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
            
            let notification = fetchedResults?.first
            
            var notifVal: Bool = true
            if notification?.value(forKey: "checkIn") != nil {
                if (sender.isOn == true) {
                    notifVal = Bool(true)
                    notification?.setValue(notifVal, forKey: "checkIn")
                } else {
                    notifVal = Bool(false)
                    notification?.setValue(notifVal, forKey: "checkIn")
                }
            }
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        appDelegate.saveContext()
    }
    
    // updates notification bool in core data
    func updateNotifications() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Notifications")
        
        var fetchedResults: [NSManagedObject]?

        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
            
            let notification = fetchedResults?.first
            if notification?.value(forKey: "checkIn") != nil {
                if checkInNotificationSwitch.isOn {
                    notification?.setValue(true, forKey: "checkIn")
                } else {
                    notification?.setValue(false, forKey: "checkIn")
                }
            }
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }

        appDelegate.saveContext()
    }
    
    // signs user out
    @IBAction func signOutButtonPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
    //resizes profile image
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
