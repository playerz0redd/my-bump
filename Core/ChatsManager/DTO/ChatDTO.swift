//
//  ChatDTO.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 5.06.26.
//

import Foundation
import FirebaseFirestore

struct ChatDTO: Decodable {
    @DocumentID var id: String?
    let members: [String]
    let lastMessage: String?
    let lastMessageTime: Date?
    let lastMessageSender: String?
}
