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
    
    @IBOutlet var messageTV: UITextView!
    
    private var messageScrollView: UIScrollView = UIScrollView()
    
    private var messages: [Message] = []
    
    private var currentMessageY: Int = 0
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Roomid: ", roomid)
        
        createMessageScrollView()
        
        loadRoom()
        
        startListeningForupdates()
    
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
    
    
    
    // called to reload the messages to the room
    private func reloadData() {
        print("Messages: ", messages.count)
        currentMessageY = 10
        for message in messages {
            createMessageView(message: message)
        }
    }
    
    private func createMessageView(message: Message) {
        let messageBodyLabel = UILabel(frame: CGRect(x: 10, y: 20, width: 150, height: heightForView(text: message.text, font: UIFont.systemFont(ofSize: 12), width: 150)))
        messageBodyLabel.numberOfLines = 0
        messageBodyLabel.lineBreakMode = .byWordWrapping
        messageBodyLabel.text = message.text
        messageBodyLabel.font = .systemFont(ofSize: 12)
        
        let messageView: UIView = UIView(frame: CGRect(x: 5, y: currentMessageY , width: 155, height: Int(messageBodyLabel.frame.height) + 30))
        messageView.addSubview(messageBodyLabel)
        
        let nameLabel: UILabel = UILabel(frame: CGRect(x: 10, y: 0, width: 150, height: 20))
        nameLabel.text = message.name
        nameLabel.font = .boldSystemFont(ofSize: 14)
        
        messageView.addSubview(nameLabel)
        
        currentMessageY = currentMessageY + Int(messageView.frame.height) + 10
        messageView.backgroundColor = #colorLiteral(red: 0.7333870591, green: 0.5166120753, blue: 0.7627034043, alpha: 1)
        messageView.layer.cornerRadius = 15
        messageScrollView.addSubview(messageView)
    }

    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
       label.numberOfLines = 0
       label.lineBreakMode = NSLineBreakMode.byWordWrapping
       label.font = font
       label.text = text

       label.sizeToFit()
       return label.frame.height
   }
    
 
    
    
    // ------------------------------------------------------------------Send Messages-------------------------------------------------------------------
    
    @IBAction func sendButtonClicked(_ sender: UIButton) {
        if messageTV.text != nil {
            print("Sending message")
            sendMessage(text: messageTV.text!, timestamp: Timestamp())
            print("Message sent")
        }
    }
    
    private func sendMessage(text: String, timestamp: Timestamp) {
        let db = Firestore.firestore()
        db.collection("chats").document(roomid).collection("messages").document(getRandomStringForMessage()).setData([
            "senderuid": Auth.auth().currentUser!.uid,
            "text": text,
            "timestamp": timestamp
        ])
    }
    
    private func getRandomStringForMessage() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<20).map{ _ in letters.randomElement()! })
    }
    
    
    // ----------------------------------------------------------------End Send Messages-------------------------------------------------------------------
    
    
    
    // ----------------------------------------------------------------Realtime Updates-------------------------------------------------------------------

    private func startListeningForupdates() {
        let db = Firestore.firestore()
        db.collection("chats").document(roomid).collection("messages")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                // reload data from database
                self.messages = []
                for document in documents {
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

    // ---------------------------------------------------------------End Realtime Updates-------------------------------------------------------------------
}
