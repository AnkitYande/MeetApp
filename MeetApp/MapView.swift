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

struct MapView: View {
    
    @ObservedObject var locationManager = LocationManager()
    @State private var landmarks: [Landmark] = [Landmark]()
    @State private var search: String = ""
    @State private var tapped: Bool = false
    @State private var animationAmount = 1.0
    @Binding var location: String
    
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
    
    func chooseLocation(chosenLocation: String) {
        self.location = chosenLocation
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            
            MapKitView(landmarks: landmarks)
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
    
    init(control: MapKitView) {
        self.control = control
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        if let annotationView = views.first {
            if let annotation = annotationView.annotation {
                if annotation is MKUserLocation {
                    let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                    mapView.setRegion(region, animated: true)
                }
            }
        }
    }
}

struct MapKitView: UIViewRepresentable {
    
    let landmarks: [Landmark]
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.showsUserLocation  = true
        map.delegate = context.coordinator
        return map
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(control: self)
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
        MapView(location: .constant(""))
    }
}
