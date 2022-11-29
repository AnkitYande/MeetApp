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
    var choose: (String, CLLocationCoordinate2D) -> ()
    var onTap: () -> ()
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Spacer()
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(.gray)
                    .frame(width: 70, height: 5)
                Spacer()
            }
            .padding(.vertical)
            .gesture(TapGesture().onEnded(self.onTap))
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onEnded({ value in
                    if value.translation.height < 0 {
                        self.onTap()
                    }
                    
                    if value.translation.height > 0 {
                        self.onTap()
                    }
                }))
            List {
                ForEach(self.landmarks, id: \.id) { landmark in
                    Place(choose: self.choose, landmark: landmark)
                }
            }.scrollContentBackground(.hidden)
        }
        .cornerRadius(10)
        .background(Color.white)
    }
}

struct Place: View {
    
    @State var showingAlert: Bool = false
    var choose: (String, CLLocationCoordinate2D) -> ()
    
    let landmark: Landmark
    
    var body: some View {
        Button(action: { self.showingAlert = true }) {
            VStack(alignment: .leading) {
                Text(landmark.name)
                    .fontWeight(.bold)
                Text(landmark.title)
            } .foregroundColor(.primary)
        }
        .alert(isPresented: $showingAlert, content: {
            Alert(
                title: Text(landmark.title),
                message: Text("Select this location?"),
                primaryButton: .cancel(
                    Text("No"),
                    action: {}
                ),
                secondaryButton: .default(
                    Text("Yes"),
                    action: { self.choose(landmark.title, landmark.coordinate) }
                ))
        })
    }
}

struct PlaceListView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceListView(landmarks: [], choose: {_,_  in }, onTap: {})
    }
}
