//
//  LoginVC.swift
//  AlexPlayground
//
//  Created by Alex Titov on 2/18/21.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    public var email: String = ""
    public var password: String = ""

    
    @IBOutlet var emailTF: UITextField!
    
    @IBOutlet var passwordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    private func checkString(string: String?) -> Bool {
        if string != nil {
            if string!.contains("@") && string!.contains(".") {
                return true
            }
        }
        return false
    }

    @IBAction func loginClicked(_ sender: UIButton) {
        if checkString(string: emailTF.text) && passwordTF.text != nil {
            email = emailTF.text!
            password = passwordTF.text!
            login()
        }
    }
    
    private func login() {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if error != nil {
                // Could not sign in
                print("Error signing in: " + error!.localizedDescription)
            } else {
                //Signed in sucessfully
                print("Sucessfully signed in")
            }
        }
    }
    
}
