//
//  PlaceListView.swift
//  MeetApp
//
//  Created by Lorenzo Martinez on 10/26/22.
//

import SwiftUI
import MapKit

struct PlaceListView: View {
    
    let landmarks: [Landmark]
    var onTap: () -> ()
    
    var body: some View {
        VStack(alignment: .leading){
            HStack {
                EmptyView()
            }.frame(width: UIScreen.main.bounds.size.width, height: 50)
                .background(Color.gray)
                .gesture(TapGesture()
                    .onEnded(self.onTap)
                )
            List {
                
                ForEach(self.landmarks, id: \.id) { landmark in
                    
                    VStack(alignment: .leading) {
                        Text(landmark.name)
                            .fontWeight(.bold)
                        
                        Text(landmark.title)
                    }
                }
            }
        }.cornerRadius(10)
    }
}

struct PlaceListView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceListView(landmarks: [], onTap: {})
//        PlaceListView(landmarks: [Landmark(placemark: MKPlacemark())], onTap: {})
    }
}
