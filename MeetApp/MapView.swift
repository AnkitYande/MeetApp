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

let defaultRegion: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50, longitude: 50), span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025))

// TODO: get placemarks for directions from Firebase
let start = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 30.422860, longitude: -97.775100))
let dest = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 30.503560, longitude: -97.756430))

struct MapView: View {
    
    @ObservedObject var locationManager = LocationManager()
    @State private var landmarks: [Landmark] = [Landmark]()
    @State private var search: String = ""
    @State private var tapped: Bool = false
    @State private var animationAmount = 1.0
    @Binding var location: String
    @State private var directions: [String] = []
    @State private var showDirections = false
    @Binding var latitude: Double
    @Binding var longitude: Double
    
    
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
    
    func calculateOffset() -> CGFloat {
        if self.landmarks.count > 0 && !self.tapped {
            return UIScreen.main.bounds.size.height - UIScreen.main.bounds.size.height / 4
        } else if self.tapped {
            return 100
        } else {
            return UIScreen.main.bounds.size.height
        }
    }
    
    func chooseLocation(chosenLocation: String, coordinate: CLLocationCoordinate2D) {
        self.location = chosenLocation
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            
            MapKitView(landmarks: landmarks, showDirections: $showDirections)
                .ignoresSafeArea()
            
            TextField("Search for a location...", text: $search, onEditingChanged: { _ in })
            {
                self.getNearbyLandmarks()
            }.textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .offset(y: 0)
            
            PlaceListView(landmarks: self.landmarks, choose: self.chooseLocation) {
                self.tapped.toggle()
            }.offset(y: calculateOffset())
        }
    }
}

class Coordinator: NSObject, MKMapViewDelegate {
    
    var control: MapKitView
    var selectionFlag: Bool
    var selectedRegion: MKCoordinateRegion
    
    init(control: MapKitView, selectionFlag: Bool = false, selectedRegion: MKCoordinateRegion = defaultRegion) {
        self.control = control
        self.selectionFlag = selectionFlag
        self.selectedRegion = selectedRegion
    }
    
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 5
        return renderer
    }
}

struct MapKitView: UIViewRepresentable {
    
    var landmarks: [Landmark]
    let address: String
    
    @State var region: MKCoordinateRegion
    @Binding var directions: [String]
    @Binding var showDirections: Bool
    
    init(landmarks: [Landmark], address: String = "", region: MKCoordinateRegion = defaultRegion, directions: Binding<[String]> = Binding.constant([]), showDirections: Binding<Bool> = Binding.constant(false)) {
        self.landmarks = landmarks
        self.address = address
        self.region = region
        self._directions = directions
        self._showDirections = showDirections
        
//        self.landmarks += [Landmark(placemark: start), Landmark(placemark: dest)]
    }
    
    func findLocationByAddress(address: String, completion: @escaping((CLLocation?) -> ())) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address, completionHandler: {(places, error) in
            guard error == nil else { completion(nil) ; return }
            completion(places![0].location!)
        })
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.showsUserLocation = true
        map.delegate = context.coordinator
        
        // TODO: get actual start and dest dependent on user
        if showDirections {
            self.updateUIView(map, context: context)
            displayDirections(map: map, start: start, dest: dest)
        }
        return map
    }
    
    func displayDirections(map: MKMapView, start: MKPlacemark, dest: MKPlacemark) {
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: start)
        request.destination = MKMapItem(placemark: dest)
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else { return }
            map.addAnnotations([start, dest])
            map.addOverlay(route.polyline)
            map.setVisibleMapRect(
                route.polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
                animated: true)
            self.directions = route.steps.map { $0.instructions }.filter { !$0.isEmpty }
        }
    }
    
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
    
    private func updateAnnotations(from mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
        let annotations = self.landmarks.map(LandmarkAnnotation.init)
        mapView.addAnnotations(annotations)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(location: .constant(""), latitude: .constant(0.0), longitude: .constant(0.0))
    }
}
