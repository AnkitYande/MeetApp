//
//  ViewController.swift
//  MeetApp
//
//  Created by Ankit Yande on 10/10/22.
//

import UIKit
import SwiftUI
import FirebaseAuth
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet var theContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        let childView = UIHostingController(rootView: HomeView())
        addChild(childView)
        childView.view.frame = theContainer.bounds
        theContainer.addSubview(childView.view)
                
        requestAuthorization(completion: { _ in })
        
//        let firebaseAuth = Auth.auth()
//        do {
//          try firebaseAuth.signOut()
//        } catch let signOutError as NSError {
//          print("Error signing out: %@", signOutError)
//        }

    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in completion(granted)
        }
    }
    
}

