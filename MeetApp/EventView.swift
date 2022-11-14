//
//  EventView.swift
//  MeetApp
//
//  Created by Ankit Yande on 10/28/22.
//

import SwiftUI
import CoreLocation
import MapKit
import FirebaseDatabase

struct EventView: View {
    
    let event:Event
    var eventViewModel:EventViewModel
    @Binding var eventList: [Event] // <-- this is literally not used anymore but the code doesn't work without it??
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var confirmed:Bool = false// Link this to core data to store status for each event?
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading){
                Text(event.eventName).font(.title).fontWeight(.semibold).padding(.top, 12.0)
                ButtonControlView(event: event, eventViewModel:eventViewModel,  eventList: $eventList)
                Group{
                    Text("Details").font(.title3).fontWeight(.semibold).padding(.top, 12.0)
                    HStack {
                        Image(systemName: "calendar").padding([.top, .trailing], 5.0).font(Font.title3.weight(.medium))
                        Text("\(formatDates(event.startDatetime,event.endDatetime))")
                    }
                    HStack {
                        Image(systemName: "clock").padding([.top, .trailing], 5.0).font(Font.title3.weight(.medium))
                        Text("\(formatTime(event.startDatetime)) - \(formatTime(event.endDatetime))")
                    }
                    HStack {
                        Image(systemName: "mappin.and.ellipse").padding([.top, .trailing], 5.0).font(Font.title3.weight(.medium))
                        Text(event.address)
                    }
                    Text("Description").font(.title3).fontWeight(.semibold).padding(.top, 24.0)
                    Text(event.description)
                }
                Text("Map").font(.title3).fontWeight(.semibold).padding(.top, 24.0)
                HStack(){
                    Spacer()
                    Minimap(address: event.address, latitude: event.latitude, longitude: event.longitude)
                    Spacer()
                }
                Text("Guests").font(.title3).fontWeight(.semibold).padding(.top, 24.0)
                Text("<Insert Social List Here>")
                if(event.host == user_id){
                    HStack(){
                        Spacer()
                        cta(text: "Delete", minWidth: 128, bgColor: Color.red, action: {
                            deleteEvent(eventID:event.UID);
                            self.presentationMode.wrappedValue.dismiss()
                        })
                        Spacer()
                    }.padding(.top, 24)
                }
            }.padding()
        }
    }
    
    func formatDates( _ start:Date, _ end:Date) -> String {
        // do not show a date if the event begins and ends on the same day
        let d1 = formatDate(start)
        let d2 = formatDate(end)
        return d1 == d2 ? d1 : "\(d1) - \(d2)"
    }
    
    func toggleStatus() -> Void {
        confirmed.toggle()
    }
}

struct Minimap: View {
    
    let address: String
    let latitude: Double
    let longitude: Double
    
    let minimapWidth = UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 7)
    let minimapHeight = CGFloat(200)
    
    var body: some View {
        MapKitView(landmarks: [Landmark(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)))], address: address, region: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), latitudinalMeters: 1000, longitudinalMeters: 1000))
            .frame(width: self.minimapWidth, height: self.minimapHeight, alignment: .center)
    }
}

func deleteEvent(eventID:String){
    
    let databaseRef = Database.database().reference()
    
    //remove event from hosting list
    databaseRef.child("users").child(user_id).child("eventsHosting").child(eventID).removeValue(completionBlock: { (error, refer) in
        guard error == nil else {
            print("Hosting: ", error!.localizedDescription)
            return;
        }})
    
    //remove from whichever list the event is in
    databaseRef.child("users").child(user_id).child("eventsInvited").child(eventID).removeValue(completionBlock: { (error, refer) in
        guard error == nil else {
            print("Invited List: ",error!.localizedDescription)
            return;
        }})
    databaseRef.child("users").child(user_id).child("eventsAccepted").child(eventID).removeValue(completionBlock: { (error, refer) in
        guard error == nil else {
            print("Accepted List: ",error!.localizedDescription)
            return;
        }})
    databaseRef.child("users").child(user_id).child("eventsDeclined").child(eventID).removeValue(completionBlock: { (error, refer) in
        guard error == nil else {
            print("Declined List: ", error!.localizedDescription)
            return;
        }})
    
    //Delete event object
    databaseRef.child("events").child(eventID).removeValue()
}


//struct EventView_Previews: PreviewProvider {
//    static var previews: some View {
//        EventView(event: testEventActive)
//    }
//}
