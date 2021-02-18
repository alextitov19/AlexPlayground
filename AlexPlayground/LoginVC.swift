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
        createUser()
    }
    
    private func createUser() {
        let db = Firestore.firestore()
        
        Auth.auth().createUser(withEmail: "test1@gmail.com", password: "mypass") { (result, err) in
            
            // Check for errors
            if err != nil {
                // There was an error creating the user
                print("Error creating user")
            }
            else {
                
                // User was created successfully, now store the attributes
                
                db.collection("users").document(result!.user.uid).setData([
                    "name": "John Smith",
                    "age": 23,
                    "country": "USA"
                ])
                
            }
        }

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
    
    private func getData() {
        guard let currentUser = Auth.auth().currentUser else {
                return
            }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(currentUser.uid)
           .getDocument { (snapshot, error ) in

                if let document = snapshot {

                    print(document.data()?.values as Any)

                } else {

                  print("Document does not exist")

                }
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
                self.getData()
            }
        }
    }
    
}
