//
//  SignupViewController.swift
//  Ignis Host
//
//  Created by Leonardo Sampaio on 13/11/16.
//  Copyright © 2016 USP. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignupViewController: UIViewController {

    @IBOutlet weak var textFieldSignupEmail: UITextField!
    @IBOutlet weak var textFieldSignupPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
            if user != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressSignup(_ sender: Any) {

        let emailField = textFieldSignupEmail.text!
        let passwordField = textFieldSignupPassword.text!
        
        FIRAuth.auth()!.createUser(withEmail: emailField,
                                   password: passwordField) { user, error in
            if error == nil {
                FIRAuth.auth()!.signIn(withEmail: self.textFieldSignupEmail.text!,
                                       password: self.textFieldSignupPassword.text!)
            } else {
                print(error!)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
}

extension SignupViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.textFieldSignupEmail {
            self.textFieldSignupPassword.becomeFirstResponder()
        }
        if textField == textFieldSignupPassword {
            textField.resignFirstResponder()
        }
        return true
    }
}
