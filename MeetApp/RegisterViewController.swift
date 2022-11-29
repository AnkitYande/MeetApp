//
//  RegisterViewController.swift
//  MeetApp
//
//  Created by William Gunawan on 10/12/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var registerEmailTextField: UITextField!
    @IBOutlet weak var registerUsernameTextField: UITextField!
    @IBOutlet weak var registerDisplayNameTextField: UITextField!
    @IBOutlet weak var registerPasswordTextField: UITextField!
    
    private let database = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerEmailTextField.delegate = self
        registerUsernameTextField.delegate = self
        registerDisplayNameTextField.delegate = self
        registerPasswordTextField.delegate = self
        overrideUserInterfaceStyle = .light
        registerEmailTextField.placeholder = "Email"
        registerUsernameTextField.placeholder = "Username"
        registerDisplayNameTextField.placeholder = "Display Name"
        registerPasswordTextField.placeholder = "Password"
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        guard registerEmailTextField.hasText && registerUsernameTextField.hasText && registerDisplayNameTextField.hasText && registerPasswordTextField.hasText else {
            let incompleteAlert = UIAlertController(
                title: "Incomplete Registration",
                message: "Please enter a valid email, username, display name, and password",
                preferredStyle: .alert
            )
            
            let okButton = UIAlertAction(
                title: "Ok",
                style: .default
            )
            
            incompleteAlert.addAction(okButton)
            present(incompleteAlert, animated: true)
            return
        }
        
        // TODO: check that username doesn't already exist in database

        Auth.auth().createUser(withEmail: registerEmailTextField.text!, password: registerPasswordTextField.text!) { authResult, error in
            guard let user = authResult?.user, error == nil else {
                print(error!.localizedDescription)
                return
            }
            user_id = user.uid
            print("\(user.email!) created")
            self.database.child("users").child(user.uid).setValue([
                "username": self.registerUsernameTextField.text!,
                "email": self.registerEmailTextField.text!,
                "displayName": self.registerDisplayNameTextField.text!,
                "profilePic": "gs://meetapp-cafdc.appspot.com/user.jpeg",
                "status": "available",
                "latitude": 0.0,
                "longitude": 0.0,
                "friends": [String: Bool](),
                "eventsInvited": [String: Bool](),
                "eventsAccepted": [String: Bool](),
                "eventsDeclined": [String: Bool](),
                "eventsHosting": [String: Bool](),
            ])
            self.performSegue(withIdentifier: "RegisterToHomeSegue", sender: self)
        }
    }
    
    @IBAction func signInButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
