//
//  FirestoreSchema.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 9.06.26.
//

import Foundation


enum FirestoreCollections: String {
    case chats = "chats"
    case messages = "messages"
    case social = "social"
    case relations = "relations"
    case users = "users"
}

enum RealtimeDatabaseCollections: String {
    case location = "location"
}

enum FirestoreFields {
    enum Chat: String {
        case members = "members"
        case lastMessage = "lastMessage"
        case lastMessageTime = "lastMessageTime"
        case unreadCount = "unreadCount"
        case lastMessageSender = "lastMessageSender"
    }
    
    enum Message: String {
        case senderId = "senderId"
        case text = "text"
        case images = "image"
        case createdAt = "createdAt"
    }
    
    enum FriendStatusField: String {
        case status = "status"
        case friendName = "friendName"
        case timestamp = "timestamp"
        case avatarPath = "avatarPath"
        case ownerId = "ownerId"
    }
    
    enum UserFields: String {
        case id = "id"
        case name = "name"
        case email = "email"
        case createdAt = "createdAt"
        case avatarId = "avatarId"
    }
}

enum RealtimeDatabaseFields {
    enum Location: String {
        case latitude = "lat"
        case longtitude = "lng"
        case timestamp = "timestamp"
    }
}
