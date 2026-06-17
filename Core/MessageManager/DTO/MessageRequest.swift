//
//  MessageRequest.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 9.06.26.
//

import Foundation

struct MessageRequest {
    let chatId: String
    let senderId: String
    let text: String?
    let images: [String]?
}
