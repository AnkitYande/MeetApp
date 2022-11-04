//
//  CreateMeetingView.swift
//  MeetAppTesting
//
//  Created by Ankit Yande on 10/17/22.
//

import SwiftUI
import FirebaseDatabase

struct CreateEventView: View {
    
    @State private var eventName: String = ""
    @State private var eventDescription: String = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var location: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                TextField("Event Name", text: $eventName)
                    .textFieldStyle(.plain)
                    .font(.title).fontWeight(.semibold)
                Text("Where?").font(.title3).fontWeight(.semibold).padding(.top, 24.0)
                NavigationLink(destination: MapView(location: $location)){
                    TextField("Search for Location", text: $location, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                }
                Text("When?").font(.title3).fontWeight(.semibold).padding(.top, 24.0)
                DatePicker(
                    "Start Time:", selection: $startDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                DatePicker(
                    "End Time:", selection: $endDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                Text("Who?").font(.title3).fontWeight(.semibold).padding(.top, 24.0)
                NavigationLink(destination: MapView(location: $location)){
                    TextField("Search for Friends/ Groups", text: $eventDescription, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                }
                Text("What?").font(.title3).fontWeight(.semibold).padding(.top, 24.0)
                TextField("Enter a Description of your event here", text: $eventDescription, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
            }.padding()
            
            cta(text:"Create Event", minWidth: 128, bgColor: Color.purple, action: createEvent)
                .fontWeight(.bold)
                .padding(.top, 48.0)
        }
    }
    
    func createEvent(){
        print(eventName, eventDescription, location, startDate, endDate)
        // TODO: add event to events object
        // TODO: add uuid of event to current user
    }
    
}

struct CreateEventView_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventView()
    }
}
