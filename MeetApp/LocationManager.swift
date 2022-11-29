//
//  LocationManager.swift
//  MeetApp
//
//  Created by Lorenzo Martinez on 10/26/22.
//

import Foundation
import MapKit
import FirebaseDatabase

class LocationManager: NSObject, ObservableObject {
    
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocation = CLLocation()
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.userLocation = location
            let databaseRef = Database.database().reference()
            databaseRef.child("users").child(user_id).updateChildValues(["latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude])
        }
    }
}
