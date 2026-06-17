//
//  MessageModel.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 16.06.26.
//

import Foundation

struct MessageModel: Hashable {
    let id: String
    let text: String?
    let images: [URL]?
    let messageTime: String
    let senderId: String
    let isMyMessage: Bool
}
