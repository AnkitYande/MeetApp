//
//  LoginViewController.swift
//  MeetApp
//
//  Created by William Gunawan on 10/12/22.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var loginEmailTextField: UITextField!
    @IBOutlet weak var loginPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        loginEmailTextField.placeholder = "Email"
        loginPasswordTextField.placeholder = "Password"
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        if loginEmailTextField.hasText && loginPasswordTextField.hasText {
            Auth.auth().signIn(withEmail: loginEmailTextField.text!, password: loginPasswordTextField.text!) { [weak self] authResult, error in
                guard let strongSelf = self else { return }
                guard let user = authResult?.user, error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                print("login successful")
                strongSelf.performSegue(withIdentifier: "loginSegue", sender: strongSelf)
            }
        } else {
            let incompleteAlert = UIAlertController(
                title: "Incomplete Login",
                message: "Please enter a valid email and password",
                preferredStyle: .alert
            )
            
            let okButton = UIAlertAction(
                title: "Ok",
                style: .default
            )
            
            incompleteAlert.addAction(okButton)
            present(incompleteAlert, animated: true)
        }
    }
    
}
