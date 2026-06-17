//
//  UserLocationResponse.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 14.05.26.
//

import Foundation

struct UserLocationResponse: Decodable {
    let id: String
    let latitude: Double
    let longtitude: Double
    let timestamp: Date
}
