//
//  LocationSyncManager.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 21.04.26.
//

import Foundation
import FirebaseDatabase
import CoreLocation
import Combine

protocol LocationSyncManagerProtocol {
    func updateLocation(userId: String, location: CLLocationCoordinate2D)
    func observeLocation(forUserId id: String) -> AnyPublisher<UserLocationResponse, Never>
}

final class LocationSyncManager: LocationSyncManagerProtocol {
    
    private let dbRef = Database.database().reference()
    
    func observeLocation(forUserId id: String) -> AnyPublisher<UserLocationResponse, Never> {
        
        let subject = PassthroughSubject<UserLocationResponse, Never>()
        let ref = dbRef.child(id).child(DatabaseCollection.location.rawValue)
        
        let listener = ref.observe(.value) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                    let lat = value[DatabaseLocationFields.latitude.rawValue] as? Double,
                    let lng = value[DatabaseLocationFields.longtitude.rawValue] as? Double,
                  let time = value[DatabaseLocationFields.timestamp.rawValue] as? NSNumber else { print("Erorr"); return }
            subject.send(.init(id: id, latitude: lat, longtitude: lng, timestamp: Date(timeIntervalSince1970: time.doubleValue / 1000)))
        }
        
        return subject
            .handleEvents(receiveCancel: {
                ref.removeObserver(withHandle: listener)
            })
            .eraseToAnyPublisher()
    }
    
    func updateLocation(userId: String, location: CLLocationCoordinate2D) {
        let locationRef = dbRef.child(userId).child(DatabaseCollection.location.rawValue)
        
        let data: [String: Any] = [
            DatabaseLocationFields.latitude.rawValue: Double(location.latitude),
            DatabaseLocationFields.longtitude.rawValue: Double(location.longitude),
            DatabaseLocationFields.timestamp.rawValue: ServerValue.timestamp()
        ]
        
        locationRef.setValue(data)
    }
}

private extension LocationSyncManager {
    
    enum DatabaseCollection: String {
        case location = "location"
    }
    
    enum DatabaseLocationFields: String {
        case latitude = "lat"
        case longtitude = "lng"
        case timestamp = "timestamp"
    }
}
