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
        self.checkInNotificationSwitch.addTarget(self, action: #selector(onSwitchValueChanged(_:)), for: .valueChanged)
        checkSwitchPosition()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkSwitchPosition()
    }
    
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
    
    @objc private func onSwitchValueChanged(_ sender: UISwitch) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Notifications")
        
        var fetchedResults: [NSManagedObject]?

        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
            
            let notification = fetchedResults?.first
            
            var notifVal: Bool = true
            print("result: \(fetchedResults)")
            if notification?.value(forKey: "checkIn") != nil {
                if (sender.isOn == true) {
                    print("ON")
                    notifVal = Bool(true)
                    notification?.setValue(notifVal, forKey: "checkIn")
                    print("should be on: \(notification?.value(forKey: "checkIn"))")
                } else {
                    print("OFF")
                    notifVal = Bool(false)
                    notification?.setValue(notifVal, forKey: "checkIn")
                    print("should be off: \(notification?.value(forKey: "checkIn"))")
                }
            }
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }

        appDelegate.saveContext()
//
//        if (sender.isOn == true){
//            updateNotifications()
//            print("UISwitch state is now ON")
//        } else {
//            print("UISwitch state is now Off")
//        }
    }
    
//    @IBAction func socialNotifSwitch(_ sender: Any) {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//
//        let context = appDelegate.persistentContainer.viewContext
//
//        let checkInNotif = NSEntityDescription.entity(forEntityName: "Notifications", in: context)
//
//        if checkInNotificationSwitch.isOn {
//            checkInNotif?.setValue(true, forKey: "social")
//        } else {
//            checkInNotif?.setValue(false, forKey: "social")
//        }
//
//        appDelegate.saveContext()
//    }
    
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
                    print("should be on: \(notification?.value(forKey: "checkIn"))")
                } else {
                    notification?.setValue(false, forKey: "checkIn")
                    print("should be off: \(notification?.value(forKey: "checkIn"))")
                }
            }
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }

        appDelegate.saveContext()
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
