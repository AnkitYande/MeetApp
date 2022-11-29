//
//  ViewController.swift
//  MeetApp
//
//  Created by Ankit Yande on 10/10/22.
//

import UIKit
import SwiftUI
import FirebaseAuth

class ViewController: UIViewController {
    
    @IBOutlet var theContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        let childView = UIHostingController(rootView: HomeView())
        addChild(childView)
        childView.view.frame = theContainer.bounds
        theContainer.addSubview(childView.view)
        
//        let firebaseAuth = Auth.auth()
//        do {
//          try firebaseAuth.signOut()
//        } catch let signOutError as NSError {
//          print("Error signing out: %@", signOutError)
//        }
    }


}

