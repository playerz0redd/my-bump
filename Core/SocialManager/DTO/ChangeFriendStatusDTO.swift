//
//  ChangeFriendStatusDTO.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 30.04.26.
//

import Foundation

struct ChangeFriendStatusDTO {
    let userFrom: UserDTO
    let userTo: UserDTO
    
    struct UserDTO {
        let id: String
        let name: String
        let avatar: String?
    }
}
