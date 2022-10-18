//
//  RegisterViewController.swift
//  MeetApp
//
//  Created by William Gunawan on 10/12/22.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var registerEmailTextField: UITextField!
    @IBOutlet weak var registerPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerEmailTextField.delegate = self
        registerPasswordTextField.delegate = self
        overrideUserInterfaceStyle = .light
        registerEmailTextField.placeholder = "Email"
        registerPasswordTextField.placeholder = "Password"
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        if registerEmailTextField.hasText && registerPasswordTextField.hasText {
            Auth.auth().createUser(withEmail: registerEmailTextField.text!, password: registerPasswordTextField.text!) { authResult, error in
                guard let user = authResult?.user, error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                print("\(user.email!) created")
            }
        } else {
            let incompleteAlert = UIAlertController(
                title: "Incomplete Registration",
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
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
