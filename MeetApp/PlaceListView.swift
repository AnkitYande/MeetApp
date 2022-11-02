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
    var choose: (String) -> ()
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
                    Place(choose: self.choose, landmark: landmark)
                }
            }
        }.cornerRadius(10)
    }
}

struct Place: View {
    
    @State var showingAlert: Bool = false
    var choose: (String) -> ()
    
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
                    action: { self.choose(landmark.title) }
                ))
        })
    }
}

struct PlaceListView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceListView(landmarks: [], choose: {_ in }, onTap: {})
    }
}
