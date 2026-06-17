//
//  MessageResponse.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 9.06.26.
//

import Foundation
import FirebaseFirestore

struct MessageResponse: Decodable {
    @DocumentID var messageId: String?
    let text: String?
    let image: [String]?
    let createdAt: Date
    let senderId: String
}
