//
//  Landmark.swift
//  MeetApp
//
//  Created by Lorenzo Martinez on 10/26/22.
//

import Foundation
import MapKit
import Contacts

struct Landmark {
    
    let placemark: MKPlacemark
    var chosenTitle: String = ""
    var customImage: UIImage = UIImage()
    var isUser: Bool = false
    
    var id: UUID {
        return UUID()
    }
    
    var name: String {
        self.placemark.name ?? ""
    }
    
    var title: String {
        self.placemark.title ?? ""
    }
    
    var coordinate: CLLocationCoordinate2D {
        self.placemark.coordinate
    }
}

final class LandmarkAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let customImage: UIImage?
    let isUser: Bool
    
    init(landmark: Landmark) {
        self.title = landmark.name == "" ? landmark.chosenTitle : landmark.name
        self.subtitle = landmark.name
        self.coordinate = landmark.coordinate
        self.customImage = landmark.customImage
        self.isUser = landmark.isUser
    }
    
    // Creates a map item based on an address and title
    func mapItem() -> MKMapItem {
        let addressDictionary = [CNPostalAddressStreetKey: title]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
}
