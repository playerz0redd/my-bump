//
//  UserDTO.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 30.04.26.
//

import Foundation

struct UserDTO: Decodable {
    let id: String
    let name: String
    let email: String
    let avatarPath: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case avatarPath = "avatarId"
    }
}
