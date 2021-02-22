//
//  message.swift
//  AlexPlayground
//
//  Created by Alex Titov on 2/21/21.
//

import UIKit
import Firebase

struct Message {
    var senderuid: String
    var name: String
    var text: String
    var timestamp: Timestamp
    
    init(senderuid: String, name: String, text: String, timestamp: Timestamp) {
        self.senderuid = senderuid
        self.text = text
        self.timestamp = timestamp
        self.name = name
    }
}
