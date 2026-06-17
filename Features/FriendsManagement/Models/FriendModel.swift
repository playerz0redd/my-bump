//
//  FriendModel.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 4.05.26.
//

import Foundation

struct FriendModel: Hashable {
    let id: String?
    let name: String
    var status: FriendStatus
    let timestamp: Date
    let avatarPath: String?
}

extension FriendModel {
    init(from dto: FriendDTO) {
        self.id = dto.id
        self.name = dto.friendName
        self.status = dto.status
        self.timestamp = dto.timestamp
        self.avatarPath = dto.avatarPath
    }
}
