//
//  LocationModel.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 15.05.26.
//

import Foundation
import CoreLocation

struct FriendLocationModel: Equatable {
    let userId: String
    let coordinates: CLLocationCoordinate2D
    let updateTime: Date
}

extension FriendLocationModel {
    init(from dto: UserLocationResponse) {
        self.coordinates = .init(latitude: dto.latitude, longitude: dto.longtitude)
        self.userId = dto.id
        self.updateTime = dto.timestamp
    }
}
