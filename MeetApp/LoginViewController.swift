//
//  LoginViewController.swift
//  MeetApp
//
//  Created by William Gunawan on 10/12/22.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var loginEmailTextField: UITextField!
    @IBOutlet weak var loginPasswordTextField: UITextField!
    
    let loginSegueIdentifier = "loginSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginEmailTextField.delegate = self
        loginPasswordTextField.delegate = self
        overrideUserInterfaceStyle = .light
        loginEmailTextField.placeholder = "Email"
        loginPasswordTextField.placeholder = "Password"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: loginSegueIdentifier, sender: self)
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        if loginEmailTextField.hasText && loginPasswordTextField.hasText {
            Auth.auth().signIn(withEmail: loginEmailTextField.text!, password: loginPasswordTextField.text!) { [weak self] authResult, error in
                guard let strongSelf = self else { return }
                guard let user = authResult?.user, error == nil else {
                    let loginErrorAlert = UIAlertController(
                        title: "Login Error",
                        message: error!.localizedDescription,
                        preferredStyle: .alert
                    )
                    let okButton = UIAlertAction(
                        title: "Ok",
                        style: .default
                    )
                    loginErrorAlert.addAction(okButton)
                    strongSelf.present(loginErrorAlert, animated: true)
                    return
                }
                print("login successful")
                print("user uid: \(user.uid)")
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
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
