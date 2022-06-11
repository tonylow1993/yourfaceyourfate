//
//  SignUpViewController.swift
//  CustomLoginDemo
//
//  Created by Christopher Ching on 2019-07-22.
//  Copyright © 2019 Christopher Ching. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.numberOfLines = 5
        passwordTextField.isSecureTextEntry = true
    }
    
    // Check the fields and validate that the data is correct. If everything is correct, this method returns nil. Otherwise, it returns the error message
    func validateFields() -> String? {
        let validator = Validator()
        
        // Check that all fields are filled in
        if validator.isAllFieldsNotEmpty(firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                                         lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                                         emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                                         passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return "Please fill in all fields."
        }
        
        // Check if the password is secure
        if (validator.isPasswordValid(passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) == false) {
            // Password isn't secure enough
            return "Please make sure your password is at least 8 characters, contains a special character and a number."
        }
        
        return nil
    }
    

    @IBAction func signUpTapped(_ sender: Any) {
        
        // Validate the fields
        let error = validateFields()
        
        if error != nil {
            
            // There's something wrong with the fields, show error message
            showError(error!)
        }
        else {
            
            // Create cleaned versions of the data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Create the user
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                
                // Check for errors
                if err != nil {
                    // There was an error creating the user
                    self.showError("Error creating user")
                }
                else {
                    let alert = UIAlertController(title: "Sign Up", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Success", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    // Transition to the home screen
                    self.transitionToHome()
                }
                
            }
            
            
            
        }
    }
    
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionToHome() {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "VC") as? ViewController
        
        view.window?.rootViewController = viewController
        view.window?.makeKeyAndVisible()
        
    }
    
}
