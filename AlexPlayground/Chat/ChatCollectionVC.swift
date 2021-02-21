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
        
        let messageCollection = db.collection("chats").document(roomid).collection("messages")
        
        messageCollection.getDocuments { (documents, error) in
            if documents?.isEmpty == false {
                print("Number of messages in this room: ", documents!.count)
            }
        }
    }
    

}
