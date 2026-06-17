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
    func observeLocation(for id: String) -> AnyPublisher<UserLocationResponse, Never>
}

final class LocationSyncManager: LocationSyncManagerProtocol {
    
    private let dbRef = Database.database().reference()
    private let milliSecsInSec: Double = 1000
    
    func observeLocation(for id: String) -> AnyPublisher<UserLocationResponse, Never> {
        
        let subject = PassthroughSubject<UserLocationResponse, Never>()
        let ref = dbRef.child(id).child(RealtimeDatabaseCollections.location.rawValue)
        
        let listener = ref.observe(.value) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  let lat = value[RealtimeDatabaseFields.Location.latitude.rawValue] as? Double,
                  let lng = value[RealtimeDatabaseFields.Location.longtitude.rawValue] as? Double,
                  let time = value[RealtimeDatabaseFields.Location.timestamp.rawValue] as? NSNumber
            else { return }
            
            let response = UserLocationResponse(
                id: id,
                latitude: lat,
                longtitude: lng,
                timestamp: Date(timeIntervalSince1970: time.doubleValue / self.milliSecsInSec)
            )
            
            subject.send(response)
        }
        
        return subject
            .handleEvents(receiveCancel: {
                ref.removeObserver(withHandle: listener)
            })
            .eraseToAnyPublisher()
    }
    
    func updateLocation(userId: String, location: CLLocationCoordinate2D) {
        let locationRef = dbRef.child(userId).child(RealtimeDatabaseCollections.location.rawValue)
        
        let data: [String: Any] = [
            RealtimeDatabaseFields.Location.latitude.rawValue: Double(location.latitude),
            RealtimeDatabaseFields.Location.longtitude.rawValue: Double(location.longitude),
            RealtimeDatabaseFields.Location.timestamp.rawValue: ServerValue.timestamp()
        ]
        
        locationRef.setValue(data)
    }
}
