//
//  ViewController.swift
//  MeetApp
//
//  Created by Ankit Yande on 10/10/22.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {
    
    @IBOutlet var theContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let childView = UIHostingController(rootView: HomeView())
        
        addChild(childView)
        childView.view.frame = theContainer.bounds
        theContainer.addSubview(childView.view)
    }


}

