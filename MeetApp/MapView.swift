//
//  MapView.swift
//  MeetApp
//
//  Created by Lorenzo Martinez on 10/26/22.
//

import SwiftUI
import MapKit
import CoreLocation
import Foundation
import Contacts
import FirebaseStorage


struct MapView: View {
    
    @ObservedObject var locationManager = LocationManager()
    @State private var landmarks: [Landmark] = [Landmark]()
    @State private var search: String = ""
    @State private var tapped: Bool = false
    @State private var animationAmount = 1.0
    @Binding var location: String
    @Binding var locationName: String
    @State private var showDirections = true
    @State private var showAllUsers = false
    @Binding var latitude: Double
    @Binding var longitude: Double
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var eventViewModel = EventViewModel(userUUID: user_id)
    var eventMap: Bool = false
    @State var users: [User] = []
    @State private var userLandmarks: [Landmark] = [Landmark]()
    let storage = Storage.storage()
    var eventName: String = ""
    var eventID: String = ""
    
    // Retrieves nearby landmarks based on search query
    // and adds them to the map
    private func getNearbyLandmarks() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = search
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if let response = response {
                let mapItems = response.mapItems
                self.landmarks = mapItems.map {
                    Landmark(placemark: $0.placemark)
                }
            }
        }
    }
    
    // Calculates the offset for the PlaceListView after searching
    func calculateOffset() -> CGFloat {
        if self.landmarks.count > 0 && !self.tapped {
            return UIScreen.main.bounds.size.height - UIScreen.main.bounds.size.height / 4
        } else if self.tapped {
            return 100
        } else {
            return UIScreen.main.bounds.size.height
        }
    }
    
    // Sets the values to pass on after selecting a location from the map
    // when creating an event
    func chooseLocation(chosenLocation: String, chosenLocationName: String, coordinate: CLLocationCoordinate2D) {
        self.location = chosenLocation
        self.locationName = chosenLocationName
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            if !eventMap {
                MapKitView(manager: locationManager, landmarks: landmarks, userLandmarks: userLandmarks, showDirections: $showDirections, showAllUsers: $showAllUsers)
                    .ignoresSafeArea()
                    .onAppear() {
                        showDirections = false
                        showAllUsers = false
                    }
                
                TextField("Search for a location...", text: $search, onEditingChanged: { _ in })
                {
                    self.getNearbyLandmarks()
                }.textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .offset(y: 0)
                
                PlaceListView(landmarks: self.landmarks, choose: self.chooseLocation) {
                    withAnimation(Animation.spring()) {
                        self.tapped.toggle()
                    }
                }.offset(y: calculateOffset())
            } else {
                MapKitView(manager: locationManager, landmarks: landmarks, userLandmarks: userLandmarks, address: location, eventLocation: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), region: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), latitudinalMeters: 1000, longitudinalMeters: 1000), showDirections: $showDirections, showAllUsers: $showAllUsers)
                    .ignoresSafeArea(edges: [.bottom, .horizontal])
                    .onAppear() {
                        userViewModel.getUsersForEvent(eventID: eventID) { eventUsers in
                            for user in eventUsers {
                                let userCoordinate = CLLocationCoordinate2D(latitude: user.latitude, longitude: user.longitude)
                                var userLandmark = Landmark(placemark: MKPlacemark(coordinate: userCoordinate), chosenTitle: user.displayName)
                                print("USER {\(user.displayName)} is at location <\(userCoordinate.latitude), \(userCoordinate.longitude)>")
                                let _ = self.storage.reference(forURL: user.profilePic).getData(maxSize: 1 * 1024 * 1024, completion: { data, error in
                                    if let error = error {
                                        print("PICTURE ERROR: \(error.localizedDescription)")
                                    } else {
                                        let image = UIImage(data: data!)!
                                        userLandmark.customImage = image
                                        userLandmark.isUser = true
                                        userLandmarks.append(userLandmark)
                                    }})
                            }
                        }
                        showAllUsers = true
                        showDirections = true
                        let eventPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                        let eventLandmark = Landmark(placemark: eventPlacemark, chosenTitle: locationName)
                        landmarks.append(eventLandmark)
                    }
                    .navigationTitle(eventName)
            }
        }.onAppear {
            eventViewModel.getEvents()
        }
    }
}

class Coordinator: NSObject, MKMapViewDelegate {
    
    var control: MapKitView
    var selectionFlag: Bool
    var selectedRegion: MKCoordinateRegion
    
    init(control: MapKitView, selectionFlag: Bool = false, selectedRegion: MKCoordinateRegion = MKCoordinateRegion()) {
        self.control = control
        self.selectionFlag = selectionFlag
        self.selectedRegion = selectedRegion
    }
    
    // Sets the initial region for the map view
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        if selectionFlag {
            mapView.setRegion(selectedRegion, animated: true)
        } else if let annotationView = views.first {
            if let annotation = annotationView.annotation {
                if annotation is MKUserLocation {
                    let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                    mapView.setRegion(region, animated: true)
                }
            }
        }
    }
    
    // Renders the overlay for displaying directions
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 5
        return renderer
    }
    
    // Customizes map annotations for the user, other users, and locations on the map,
    // setting icon images to profile pictures for other users
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "")
        if annotation is MKUserLocation {
            return nil
        } else if annotation is LandmarkAnnotation {
            let landmarkAnnotation = annotation as! LandmarkAnnotation
            if landmarkAnnotation.isUser {
                annotationView.image = landmarkAnnotation.customImage
                annotationView.canShowCallout = true
                let size = CGSize(width: 30, height: 30)
                annotationView.image = UIGraphicsImageRenderer(size:size).image { _ in
                    annotationView.layer.borderWidth = 1
                    annotationView.layer.borderColor = CGColor.init(red: 0, green: 0, blue: 0, alpha: 1)
                    annotationView.layer.backgroundColor = CGColor.init(red: 0, green: 0, blue: 0, alpha: 1)
                    annotationView.image!.draw(in:CGRect(origin:.zero, size:size))
                }
            } else {
                let anot = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "")
                anot.canShowCallout = true
                anot.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                return anot
            }
        }
        return annotationView
    }
    
    // Displays directions from the selected user annotation to the event
    // location, clearing the map of any paths shown before
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            let startingCoordinate = annotation.coordinate
            if !(annotation is MKUserLocation) {
                let landmarkAnnotation = annotation as! LandmarkAnnotation
                if !landmarkAnnotation.isUser {
                    return
                }
            }
            mapView.removeOverlays(mapView.overlays)
            control.displayDirections(map: mapView, start: MKPlacemark(coordinate: startingCoordinate))
        }
    }
    
    // Launches Apple Maps with directions to the event location when the callout
    // accessory item is selected for a location annotation
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation {
            if annotation is LandmarkAnnotation {
                let landmarkAnnotation = annotation as! LandmarkAnnotation
                let launchOptions = [MKLaunchOptionsMapCenterKey: landmarkAnnotation.coordinate]
                landmarkAnnotation.mapItem().openInMaps(launchOptions: launchOptions)
            }
        }
    }
}

struct MapKitView: UIViewRepresentable {
    
    var manager: LocationManager
    var landmarks: [Landmark]
    var userLandmarks: [Landmark]
    var address: String = ""
    var eventLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    @State var region: MKCoordinateRegion = MKCoordinateRegion()
    @Binding var showDirections: Bool
    @Binding var showAllUsers: Bool
    
    // Outputs a location from an input address string
    func findLocationByAddress(address: String, completion: @escaping((CLLocation?) -> ())) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address, completionHandler: {(places, error) in
            guard error == nil else { completion(nil) ; return }
            completion(places![0].location!)
        })
    }
    
    // Initializes the map view, showing directions if flag is set
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.showsUserLocation = true
        map.delegate = context.coordinator
        
        if showDirections {
            let _ = manager.$userLocation.sink(receiveValue: { newLocation in
                print("User location updated to: \(newLocation)")
                displayDirections(map: map, start: MKPlacemark(coordinate: newLocation.coordinate))
            })
        }
        return map
    }
    
    // Creates a directions request and renders the path from the start
    // location to the event location
    func displayDirections(map: MKMapView, start: MKPlacemark) {
        let dest = MKPlacemark(coordinate: eventLocation)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: start)
        request.destination = MKMapItem(placemark: dest)
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else { return }
            map.addOverlay(route.polyline)
            map.setVisibleMapRect(
                route.polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100),
                animated: true)
            print(eta(seconds: route.expectedTravelTime))
        }
    }
    
    // Returns a string displaying the seconds of a trip
    // in a more readable format
    func eta(seconds: Double) -> String {
      let (hr,  minf) = modf(seconds / 3600)
      let (min, secf) = modf(60 * minf)
      return "ETA: \(Int(hr)) hour(s), \(Int(min)) minute(s), and \(String(format: "%.0f", 60 * secf)) second(s)"
    }
    
    // Customizes the coordinator object with a selected region if chosen
    func makeCoordinator() -> Coordinator {
        if address != "" {
            return Coordinator(control: self, selectionFlag: true, selectedRegion: region)
        } else {
            return Coordinator(control: self)
        }
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapKitView>) {
        updateAnnotations(from: uiView)
    }
    
    // Adds location landmarks as annotations on the map, adding user
    // landmarks if the flag is set
    private func updateAnnotations(from mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
        var annotations = self.landmarks.map(LandmarkAnnotation.init)
        if showAllUsers {
            annotations += self.userLandmarks.map(LandmarkAnnotation.init)
        }
        mapView.addAnnotations(annotations)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(location: .constant(""), locationName: .constant(""), latitude: .constant(0.0), longitude: .constant(0.0))
    }
}
