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
//    @State var eventList:[Event] = [] // for preview testing
    
    @State var invitees:(acceptedList:[String], declinedList:[String], invitedList:[String]) = ([],[],[])
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading){
                Text(event.eventName).font(.title).fontWeight(.semibold).padding(.top, 12.0)
                ButtonControlView(event: event, eventViewModel:eventViewModel, eventList: $eventList)
                
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
                RSVP(invitees: $invitees)
                
                if(event.host == user_id){
                    HStack(){
                        Spacer()
                        cta(text: "Delete", minWidth: 128, bgColor: Color.red, action: {
                            deleteEvent(eventID:event.UID);
                            self.presentationMode.wrappedValue.dismiss()
                        })
                        Spacer()
                    }.padding(.top, 32)
                }
            }.padding()
        }
        .refreshable {
            // eventViewModel.getEvents()
            loadInvitees(eventID: event.UID)
        }
        .onAppear {
            loadInvitees(eventID: event.UID)
        }
    }
    
    func formatDates( _ start:Date, _ end:Date) -> String {
        // do not show a date if the event begins and ends on the same day
        let d1 = formatDate(start)
        let d2 = formatDate(end)
        return d1 == d2 ? d1 : "\(d1) - \(d2)"
    }
    
    func loadInvitees(eventID:String) {
        let databaseRef = Database.database().reference()
        databaseRef.child("events").child(eventID).getData(completion: { error, snapshot in
            guard error == nil else {
                print(error!.localizedDescription)
                return;
            }
            var invitedList:[String] = []
            var acceptedList:[String] = []
            var declinedList:[String] = []
            
            let eventDict = snapshot?.value as? [String: Any] ?? [String: Any]();
            
            if let usersInvited = eventDict["usersInvited"] as? [String: Any] {
                for (userUUID, _) in usersInvited {
                    invitedList.append(userUUID)
                }
            }
            
            if let usersAccepted = eventDict["usersAccepted"] as? [String: Any] {
                for (userUUID, _) in usersAccepted {
                    acceptedList.append(userUUID)
                }
            }
            
            if let usersDeclined = eventDict["usersDeclined"] as? [String: Any] {
                for (userUUID, _) in usersDeclined {
                    declinedList.append(userUUID)
                }
            }
            self.invitees = (acceptedList, declinedList, invitedList)
        })
    }
    
}

struct Minimap: View {
    
    @ObservedObject var locationManager = LocationManager()
    
    let address: String
    let latitude: Double
    let longitude: Double
    
    let minimapWidth = UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 7)
    let minimapHeight = CGFloat(200)
    
    @State private var showDirections = false
    @State private var showAllUsers = false
    @State private var userLandmarks: [Landmark] = [Landmark]()
    
    var body: some View {
        MapKitView(manager: locationManager, landmarks: [Landmark(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)), chosenTitle: address)], userLandmarks: userLandmarks, address: address, region: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), latitudinalMeters: 1000, longitudinalMeters: 1000), showDirections: $showDirections, showAllUsers: $showAllUsers)
            .frame(width: self.minimapWidth, height: self.minimapHeight, alignment: .center)
    }
}

struct RSVP: View {
    @Binding var invitees: (acceptedList:[String], declinedList:[String], invitedList:[String])
    var body: some View {
        HStack(){
            Spacer()
            RSVPCard(label: "Accepted", inviteeList: invitees.acceptedList)
            Spacer()
            RSVPCard(label: "Invited", inviteeList: invitees.invitedList)
            Spacer()
            RSVPCard(label: "Declined", inviteeList: invitees.declinedList)
            Spacer()
        }
    }
}

struct RSVPCard:View{
    let label:String
    let inviteeList:[String]
    var body: some View {
        NavigationLink(destination:GuestList(userList: inviteeList)){
            VStack{
                Text(label)
                    .foregroundColor(Color.black)
                Text("\(inviteeList.count)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
            }.padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.gray, radius: 1)
        }
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
    
    // iterate through usersAccepted, usersInvited, usersDeclined and remove this event from those users
    databaseRef.child("events").child(eventID).child("usersAccepted").getData(completion: { error, snapshot in
        guard error == nil else {
            print(error!.localizedDescription)
            return;
        }
        let usersAccepted = snapshot?.value as? [String: Any] ?? [String: Any]();
        for (userUUID, _) in usersAccepted {
            databaseRef.child("users").child(userUUID).child("eventsAccepted").child(eventID).removeValue()
        }
    })
    
    databaseRef.child("events").child(eventID).child("usersInvited").getData(completion: { error, snapshot in
        guard error == nil else {
            print(error!.localizedDescription)
            return;
        }
        let usersInvited = snapshot?.value as? [String: Any] ?? [String: Any]();
        for (userUUID, _) in usersInvited {
            databaseRef.child("users").child(userUUID).child("eventsInvited").child(eventID).removeValue()
        }
    })
    
    databaseRef.child("events").child(eventID).child("usersDeclined").getData(completion: { error, snapshot in
        guard error == nil else {
            print(error!.localizedDescription)
            return;
        }
        let usersDeclined = snapshot?.value as? [String: Any] ?? [String: Any]();
        for (userUUID, _) in usersDeclined {
            databaseRef.child("users").child(userUUID).child("eventsDeclined").child(eventID).removeValue()
        }
    })
    
    //Delete event object
    databaseRef.child("events").child(eventID).removeValue()
}


//struct EventView_Previews: PreviewProvider {
//    static var previews: some View {
//        EventView(event: testEventActive, eventViewModel: EventViewModel(userUUID: user_id))
//    }
//}
