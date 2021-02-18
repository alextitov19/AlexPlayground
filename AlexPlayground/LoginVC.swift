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
    
//    private func createUser() {
//        let db = Firestore.firestore()
//
//        Auth.auth().createUser(withEmail: "test2@gmail.com", password: "mypass2") { (result, err) in
//
//            // Check for errors
//            if err != nil {
//                // There was an error creating the user
//                print("Error creating user")
//            }
//            else {
//
//                // User was created successfully, now store the attributes
//
//                db.collection("users").document(result!.user.uid).setData([
//                    "name": "Rachel White",
//                    "age": 22,
//                    "country": "USA"
//                ])
//
//            }
//        }
//
//    }
//
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
        
        let docRef = db.collection("users").document(currentUser.uid)
            
            
           docRef.getDocument { (document, error ) in

            if let document = document, document.exists {

                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
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
                self.performSegue(withIdentifier: "toChatsCollection", sender: nil)
            }
        }
    }
    
}
