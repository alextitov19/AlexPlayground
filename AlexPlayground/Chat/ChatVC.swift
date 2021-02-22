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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Roomid: ", roomid)
        
        createMessageScrollView()
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
                    
                }
            }
        }
        
    }
    
    private func displayMessage(name: String, text: String) {
        
    }
    
    
    
    
    @IBAction func sendButtonClicked(_ sender: UIButton) {
        
    }
    
}
