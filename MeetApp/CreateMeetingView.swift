//
//  CreateMeetingView.swift
//  MeetAppTesting
//
//  Created by Ankit Yande on 10/17/22.
//

import SwiftUI


struct CreateEventView: View {
    
    @State private var eventName: String = ""
    @State private var eventDescription: String = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                TextField("Event Name", text: $eventName)
                    .textFieldStyle(.plain)
                    .font(.title).fontWeight(.semibold)
                Text("Where?").font(.title3).fontWeight(.semibold).padding(.top, 24.0)
                NavigationLink(destination: MapView()){
                    TextField("Search for Location", text: $eventDescription, axis: .vertical)
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
                NavigationLink(destination: MapView()){
                    TextField("Search for Friends/ Groups", text: $eventDescription, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                }
                Text("What?").font(.title3).fontWeight(.semibold).padding(.top, 24.0)
                TextField("Enter a Description of your event here", text: $eventDescription, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
            }.padding()
            
            cta(text:"Create Event", minWidth: 128, action: printAction)
                .fontWeight(.bold)
                .padding(.top, 48.0)
        }
    }
    
    func printAction(){
        print(eventName, eventDescription, startDate, endDate)
    }
    
}

struct CreateEventView_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventView()
    }
}
