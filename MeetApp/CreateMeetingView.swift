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
    @State private var friendsInvited: [User] = [User]()
    @State private var friendsInvitedString: String = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var location: String = ""
    @State private var latitude: Double = 0.0
    @State private var longitude: Double = 0.0
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                TextField("Event Name", text: $eventName)
                    .textFieldStyle(.plain)
                    .font(.title).fontWeight(.semibold)
                Text("Where?").font(.title3).fontWeight(.semibold).padding(.top, 24.0)
                NavigationLink(destination: MapView(location: $location, latitude: $latitude, longitude: $longitude)){
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
                NavigationLink(destination: FriendSelectView(delegate: self)){
                    TextField("Search for Friends/ Groups", text: $friendsInvitedString, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                }
                Text("What?").font(.title3).fontWeight(.semibold).padding(.top, 24.0)
                TextField("Enter a Description of your event here", text: $eventDescription, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
            }.padding()
            cta(text:"Create Event", minWidth: 128, bgColor: Color.purple, action: createEvent)
                .fontWeight(.bold)
                .padding(.top, 48.0)
        }.onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
    }
    
    func updateFriendsInvited(newFriends: [User]) {
        self.friendsInvited = newFriends
        let names = newFriends.map { $0.displayName }
        self.friendsInvitedString = names.joined(separator: ", ")
    }
    
    func createEvent() {
        
        let databaseRef = Database.database().reference()
        
        databaseRef.child("users").getData(completion: { error, snapshot in
            guard error == nil else {
                print(error!.localizedDescription)
                return;
            }
            
//            var allUsersDict = snapshot?.value as? [String: AnyObject] ?? [:]
//
//            for (userId, _) in allUsersDict {
//                allUsersDict[userId] = true as AnyObject
//            }
            var invitedDict = [String: Bool]()
            invitedDict[user_id] = true // invite yourself
            for user in self.friendsInvited {
                invitedDict[user.UID] = true
            }
            
            // add event to events object
            let eventUUID = UUID().uuidString
            databaseRef.child("events").child(eventUUID).setValue([
                "eventName": self.eventName,
                "location": self.location,
                "latitude": self.latitude,
                "longitude": self.longitude,
                "startDatetime": self.startDate.description,
                "endDatetime": self.endDate.description,
                "description": self.eventDescription,
                "usersInvited": invitedDict,
                "usersAccepted": [String: Bool](),
                "usersDeclined": [String: Bool](),
                "host": user_id
            ])
            
            // add uuid of event to current user
            databaseRef.child("users").child(user_id).child("eventsHosting").child(eventUUID).setValue(true)
            
            // add uuid of event to invited users
            for (userId, _) in invitedDict {
                databaseRef.child("users").child(userId).child("eventsInvited").child(eventUUID).setValue(true)
            }
            
            print("Event ", eventName, " UID: ", eventUUID, " created" )
            
            self.presentationMode.wrappedValue.dismiss()
            
        })
        
    }
}

struct CreateEventView_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventView()
    }
}

struct FriendSelectView: UIViewControllerRepresentable {
    typealias UIViewControllerType = SocialViewController
    var delegate : CreateEventView
    
    func makeUIViewController(context: Context) -> SocialViewController {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let viewController = sb.instantiateViewController(identifier: "SocialViewController") as! SocialViewController
        viewController.viewMode = SocialViewMode.selectView
        viewController.delegate = self.delegate
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: SocialViewController, context: Context) {
        
    }
}
