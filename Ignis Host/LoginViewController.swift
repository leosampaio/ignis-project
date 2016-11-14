//
//  ViewController.swift
//  Ignis Host
//
//  Created by Leonardo Sampaio on 13/11/16.
//  Copyright © 2016 USP. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.contentSize = contentView.bounds.size;
        
        self.textFieldLoginEmail.delegate = self
        self.textFieldLoginPassword.delegate = self

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

    @IBAction func didPressLogin(_ sender: Any) {
        FIRAuth.auth()!.signIn(withEmail: textFieldLoginEmail.text!,
                               password: textFieldLoginPassword.text!)
    }
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue) {
        
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldLoginEmail {
            textFieldLoginPassword.becomeFirstResponder()
        }
        if textField == textFieldLoginPassword {
            textField.resignFirstResponder()
            let newOffset = CGPoint(x:0, y:0);
            self.scrollView.setContentOffset(newOffset, animated: true)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let newOffset = CGPoint(x:0, y:textField.frame.origin.y-200);
        self.scrollView.setContentOffset(newOffset, animated: true)
    }
}

