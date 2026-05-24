//
//  FriendDTO.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 30.04.26.
//

import Foundation
import FirebaseFirestore

struct FriendDTO: Decodable {
    @DocumentID var id: String?
    let friendName: String
    let status: FriendStatus
    let timestamp: Date
    let avatarPath: String?
}
