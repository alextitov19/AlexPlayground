//
//  ChatVC.swift
//  AlexPlayground
//
//  Created by Alex Titov on 2/20/21.
//

import UIKit
import Firebase

class ChatVC: UIViewController {
    
    public var roomid: String = ""

    
    @IBOutlet var topView: UIView!
    
    @IBOutlet var roomNameLabel: UILabel!
    
    @IBOutlet var bottomView: UIView!
    
    @IBOutlet var messageTF: UITextView!
    
    private var messageScrollView: UIScrollView = UIScrollView()
    
    private var messages: [Message] = []
    
    private var currentMessageName: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Roomid: ", roomid)
        
        createMessageScrollView()
        
        loadRoom()
    
    }
    
    private func createMessageScrollView() {
        messageScrollView = UIScrollView(frame: CGRect(x: 0, y: topView.frame.maxY, width: view.frame.width, height: bottomView.frame.minY - topView.frame.maxY))
        messageScrollView.backgroundColor = .lightGray
        view.addSubview(messageScrollView)
    }
    
    
    
    
    
    private func loadRoom() {
        let db = Firestore.firestore()
        // get the collection of messages
        let messageCollection = db.collection("chats").document(roomid).collection("messages")
        
        messageCollection.getDocuments { (documents, error) in
            if documents?.isEmpty == false {
                for document in documents!.documents {
                    // going throught all the messages in the room
                    // TODO: Display all messages
                    guard let senderuid = document.data()["senderuid"] as? String else {return}
                    guard let text = document.data()["text"] as? String else {return}
                    guard let timestamp = document.data()["timestamp"] as? Timestamp else {return}
                    
                    let db = Firestore.firestore()
                    let docRef = db.collection("users").document(senderuid)
                    docRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            // attempt to get the name from the doc
                            guard let name = document.data()!["name"] as? String else {
                                print("Failed to find name")
                                return
                            }
                            // Create the room with the name and text attributes
                            let message = Message(senderuid: senderuid, name: name, text: text, timestamp: timestamp)
                            self.messages.append(message)
                            self.reloadData()
                            
                        } else {
                            print("Document does not exist")
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    private func reloadData() {
        print("Messages: ", messages.count)
        
    }

    
    private func displayMessage(name: String, text: String) {
        
    }
    
    
    
    
    @IBAction func sendButtonClicked(_ sender: UIButton) {
        
    }
    
}
