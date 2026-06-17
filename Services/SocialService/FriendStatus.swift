//
//  FriendStatus.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 30.04.26.
//

import Foundation

enum FriendStatus: String, Decodable {
    case requesting = "requesting"
    case responsing = "responsing"
    case friends = "friends"
    case block = "block"
    case removeFriend = "removeFriend"
    case unknown = "unknown"
}
