//
//  UserModel.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 30.04.26.
//

import Foundation

struct UserModel: Hashable {
    let id: String
    let name: String
    let email: String
    let avatarPath: String?
}

extension UserModel {
    init(from dto: UserDTO) {
        self.id = dto.id
        self.name = dto.name
        self.email = dto.email
        self.avatarPath = dto.avatarPath
    }
}
