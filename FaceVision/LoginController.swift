//
//  ViewController.swift
//  FaceVision
//
//  Created by Tony Low on 16/02/2018.
//  Copyright © 2017 Gotcha Studio. All rights reserved.
//

import UIKit
import FirebaseAuth

@available(iOS 11.0, *)
class LoginController: UIViewController, UINavigationControllerDelegate{
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
        
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        errorLabel.numberOfLines = 5
        passwordTextField.isSecureTextEntry = true
    }
    
    @IBAction func loginTapped(_ sender: Any) {
            
            // TODO: Validate Text Fields
            
            // Create cleaned versions of the text field
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Signing in the user
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                
                if error != nil {
                    // Couldn't sign in
                    self.errorLabel.text = error!.localizedDescription
                    self.errorLabel.alpha = 1
                }
                else {
                    
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "VC") as? ViewController
                    
                    self.view.window?.rootViewController = viewController
                    self.view.window?.makeKeyAndVisible()
                }
            }
        }
    
    @objc private func didTapButton() {
        print("Continue")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


