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
    
    private var roomCount: Int = 0
    private var currentRoom: Int = 0
    
    private var buttons: [UIButton] = []
    private var roomids: [String] = []
    
    private var roomidToSend: String = ""

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createScrollView()
        getData()
    }
    
    // create the scroll view that hosts all of the message views
    private func createScrollView() {
        scrollView = UIScrollView(frame: CGRect(x: 0, y: topView.frame.maxY, width: view.frame.width, height: view.frame.height - topView.frame.height))
        scrollView.backgroundColor = .lightGray
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height)
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
                self.roomCount = rooms.count
                for room in rooms {
                    self.roomids.append(room)
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
                // Create the room with the name and text attributes
                self.createRoomView(name: name, body: text)
            } else {
                print("Document does not exist")
            }
        }
        
        
    }
    
    // Create the UIView for the room and add it to the scrollview
    private func createRoomView(name: String, body: String) {
        print("Name: \(name), body: \(body)")
        print(roomCount)
        
        let roomView: UIView = UIView(frame: CGRect(x: 0, y: 10 + currentRoom * 70, width: Int(scrollView.frame.width), height: 60))
        roomView.translatesAutoresizingMaskIntoConstraints = false
        roomView.backgroundColor = .darkGray

        scrollView.addSubview(roomView)
        
        let bodyLabel = UILabel(frame: CGRect(x: 60, y: 35, width: roomView.frame.width - 80, height: 20))
        bodyLabel.text = body
        
        let nameLabel = UILabel(frame: CGRect(x: 60, y: 5, width: roomView.frame.width - 80, height: 30))
        nameLabel.text = name
        nameLabel.font = .boldSystemFont(ofSize: 20)
        
        let button: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: roomView.frame.width, height: roomView.frame.height))
        button.backgroundColor = .clear
        button.addTarget(self, action:#selector(roomClicked(sender:)), for: .touchUpInside)
        
        roomView.addSubview(nameLabel)
        roomView.addSubview(bodyLabel)
        roomView.addSubview(button)
        
        buttons.append(button)
        
        currentRoom += 1
    }
    
    @objc func roomClicked(sender: UIButton) {
        guard let index = buttons.firstIndex(of: sender) else {
            print("Could not find button of the current room in buttons")
            return
        }
        roomidToSend = roomids[index]
        performSegue(withIdentifier: "toChatRoom", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ChatVC
        {
            let vc = segue.destination as? ChatVC
            vc?.roomid = roomidToSend
        }
    }
    
    
    

}
