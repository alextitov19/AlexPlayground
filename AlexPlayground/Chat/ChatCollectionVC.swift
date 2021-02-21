//
//  ChatCollectionVC.swift
//  AlexPlayground
//
//  Created by Alex Titov on 2/20/21.
//

import UIKit
import Firebase

class ChatCollectionVC: UIViewController {
    
    @IBOutlet var topView: UIView!
    
    private var scrollView: UIScrollView = UIScrollView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createScrollView()
        getData()
    }
    
    // create the scroll view that hosts all of the message views
    private func createScrollView() {
        scrollView = UIScrollView(frame: CGRect(x: 0, y: topView.frame.maxY, width: view.frame.width, height: view.frame.height - topView.frame.height))
        scrollView.backgroundColor = .green
        view.addSubview(scrollView)
    }
    
    // load data for the current user, loading the rooms
    private func getData() {
        guard let currentUser = Auth.auth().currentUser else {
                return
            }
        
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(currentUser.uid)
        docRef.getDocument { (document, error ) in

            if let document = document, document.exists {
                let rooms: [String] = document.data()!["rooms"] as! [String]
                for room in rooms {
                    self.loadRoom(roomid: room)
                }
                    
            }
        }
    }
    
    
    // load and display the specific room
    private func loadRoom(roomid: String) {
        let db = Firestore.firestore()
        // get the collection of messages
        let messageCollection = db.collection("chats").document(roomid).collection("messages")
        // get all documents in messages
        messageCollection.getDocuments { (documents, error) in
            if documents?.isEmpty == false {
                let latestTimestamp: Timestamp = Timestamp(date: Date(timeIntervalSince1970: 0))
                var latestDoc: DocumentSnapshot?
                for document in documents!.documents {
                    // going throught all the messages in the room
                    let messageTimestamp = document.data()["timestamp"] as! Timestamp
                    
                    if messageTimestamp.seconds > latestTimestamp.seconds  {
                        // this message is newer than the latest message
                        latestDoc = document
                    }
                }
                // by now, latestDoc represents the latest message, and can not be nil
                self.loadDataForRoomView(doc: latestDoc!)
            }
        }
    }
    
    private func loadDataForRoomView(doc: DocumentSnapshot) {
        // sender id
        guard let senderuid = doc.data()!["senderuid"] as? String else {
            print("Failed to find senderuid")
            return
        }
        // message text
        guard let text = doc.data()!["text"] as? String else {
            print("Failed to find text")
            return
        }

        let db = Firestore.firestore()
        let docRef = db.collection("users").document(senderuid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // attempt to get the name from the doc
                guard let name = document.data()!["name"] as? String else {
                    print("Failed to find name")
                    return
                }
                self.createRoomView(name: name, body: text)
            } else {
                print("Document does not exist")
            }
        }
        
        
    }
    
    private func createRoomView(name: String, body: String) {
       print("Name: \(name), body: \(body)")
    }
    

}
