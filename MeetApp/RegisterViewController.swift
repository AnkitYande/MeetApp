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
    @IBOutlet weak var registerPasswordTextField: UITextField!
    
    private let database = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerEmailTextField.delegate = self
        registerUsernameTextField.delegate = self
        registerPasswordTextField.delegate = self
        overrideUserInterfaceStyle = .light
        registerEmailTextField.placeholder = "Email"
        registerUsernameTextField.placeholder = "Username"
        registerPasswordTextField.placeholder = "Password"
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        guard registerEmailTextField.hasText && registerUsernameTextField.hasText && registerPasswordTextField.hasText else {
            let incompleteAlert = UIAlertController(
                title: "Incomplete Registration",
                message: "Please enter a valid email, username, and password",
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
                "profilePic": "gs://meetapp-cafdc.appspot.com/user.jpeg"
            ])
        }
    }
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
