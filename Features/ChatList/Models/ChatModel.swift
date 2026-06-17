//
//  ChatModel.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 5.06.26.
//

import Foundation

nonisolated struct ChatModel: Hashable, Sendable {
    let id: String
    let userWithName: String
    let avatar: URL?
    let lastMessage: String?
    let lastMessageTime: String?
    let lastMessageUserId: String?
    let unreadCount: String?
}
