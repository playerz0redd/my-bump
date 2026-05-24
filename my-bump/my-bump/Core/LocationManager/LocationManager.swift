//
//  LocationManager.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 21.04.26.
//

import Foundation
import CoreLocation
import Combine

protocol LocationManagerProtocol {
    func startTracking()
    func stopTracking()
    func requestPermission()
    
    var locationPublisher: PassthroughSubject<CLLocation, Never> { get }
}

final class LocationManager: NSObject, CLLocationManagerDelegate, LocationManagerProtocol {
    
    let locationPublisher = PassthroughSubject<CLLocation, Never>()
    
    private let manager: CLLocationManager = .init()
    private let MIN_DISTANCE: CLLocationDistance = 40
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = true
        manager.showsBackgroundLocationIndicator = true
        manager.distanceFilter = MIN_DISTANCE
    }
    
    func startTracking() {
        manager.startUpdatingLocation()
    }
    
    func stopTracking() {
        manager.stopUpdatingLocation()
    }
    
    func requestPermission() {
        manager.requestAlwaysAuthorization()
    }
    
    func locationManager( _ locationManager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationPublisher.send(location)
        }
    }
    
    
}

