//
//  EventViewModel.swift
//  MeetApp
//
//  Created by Bo Deng on 11/6/22.
//

import Foundation
import FirebaseDatabase

final class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    
    var userUUID: String
    
    init(userUUID: String) {
        self.userUUID = userUUID
    }
    
    func getEvents() {
        print("fetching events")
        self.events = []
        
        let databaseRef = Database.database().reference()
        
        databaseRef.child("users").child(userUUID).child("eventsInvited").getData(completion: { error, snapshot in
            guard error == nil else {
                print(error!.localizedDescription)
                return;
            }
            let eventsInvited = snapshot?.value as? [String: Any] ?? [String: Any]();
            for (eventUUID, _) in eventsInvited {
                databaseRef.child("events").child(eventUUID).getData(completion: { error, snapshot in
                    guard error == nil else {
                        print(error!.localizedDescription)
                        return;
                    }
                    if let eventDict = snapshot?.value as? [String: Any]{
                        if let newEvent = processEventDict(eventDict: eventDict, uuid: eventUUID, status: .active){
                            self.events.append(newEvent)
                        }
                    }
                })
            }
        })
        
        databaseRef.child("users").child(userUUID).child("eventsAccepted").getData(completion: { error, snapshot in
            guard error == nil else {
                print(error!.localizedDescription)
                return;
            }
            let eventsAccepted = snapshot?.value as? [String: Any] ?? [String: Any]();
            for (eventUUID, _) in eventsAccepted {
                databaseRef.child("events").child(eventUUID).getData(completion: { error, snapshot in
                    guard error == nil else {
                        print(error!.localizedDescription)
                        return;
                    }
                    if let eventDict = snapshot?.value as? [String: Any]{
                        if let newEvent = processEventDict(eventDict: eventDict, uuid: eventUUID, status: .accepted){
                            self.events.append(newEvent)
                        }
                    }
                })
            }
        })
        
        databaseRef.child("users").child(userUUID).child("eventsDeclined").getData(completion: { error, snapshot in
            guard error == nil else {
                print(error!.localizedDescription)
                return;
            }
            let eventsDeclined = snapshot?.value as? [String: Any] ?? [String: Any]();
            for (eventUUID, _) in eventsDeclined {
                databaseRef.child("events").child(eventUUID).getData(completion: { error, snapshot in
                    guard error == nil else {
                        print(error!.localizedDescription)
                        return;
                    }
                    if let eventDict = snapshot?.value as? [String: Any]{
                        if let newEvent = processEventDict(eventDict: eventDict, uuid: eventUUID, status: .declined){
                            self.events.append(newEvent)
                        }
                    }
                })
            }
        })
        
        func processEventDict(eventDict:[String: Any], uuid: String, status:EventState) -> Event? {
            if let eventName = eventDict["eventName"] as? String,
               let location = eventDict["location"] as? String,
               let locationName = eventDict["locationName"] as? String,
               let latitude = eventDict["latitude"] as? Double,
               let longitude = eventDict["longitude"] as? Double,
               let startDatetime = eventDict["startDatetime"] as? String,
               let endDatetime = eventDict["endDatetime"] as? String,
               let description = eventDict["description"] as? String,
               let host = eventDict["host"] as? String
            {
                
                var attendeesList = [String]()
                if let usersInvited = eventDict["usersInvited"] as? [String: Any] {
                    for (userUUID, _) in usersInvited {
                        attendeesList.append(userUUID)
                    }
                }
                if let usersAccepted = eventDict["usersAccepted"] as? [String: Any] {
                    for (userUUID, _) in usersAccepted {
                        attendeesList.append(userUUID)
                    }
                }
                if let usersDeclined = eventDict["usersDeclined"] as? [String: Any] {
                    for (userUUID, _) in usersDeclined {
                        attendeesList.append(userUUID)
                    }
                }
                
                let newEvent = Event(UID: uuid, eventName: eventName, startDatetime: startDatetime, endDatetime: endDatetime, address: location, locationName: locationName, latitude: latitude, longitude: longitude, description: description, attendees: attendeesList.joined(separator: ", "), host: host, status: status)
                return newEvent
            }
            return nil
        }
    }
    
    
    
    func loadDummyData(){
        self.events = []
        let eventsList = [testEventConfirmed,testEventDeclined,testEventActive,testEventExpired1,testEventExpired2]
        self.events = eventsList
    }
}

// FOR TESTING
let _eventName:String = "Party at Bo's"
let _pastStartDatetime:String = "2022-10-30 22:00:00 +0000"
let _pastEndDatetime:String = "2022-10-31 22:26:00 +0000"
let _startDatetime:String = "2023-10-30 22:00:00 +0000"
let _endDatetime:String = "2023-10-31 22:26:00 +0000"
let _address:String = "2111 Rio Grande St, Austin, TX 78705"
let _locationName:String = "Villas on Rio"
let _latitude:Double = 30.284680
let _longitude:Double = -97.744940
let _description:String = "Bo is throwing the most popping party in all of Wampus!  Come on through for this great networking opportunity"
let _attendees:String = ""
let _host:String = "Bo Deng"
let testEventConfirmed = Event(UID: UUID().uuidString, eventName: _eventName, startDatetime: _startDatetime, endDatetime: _endDatetime, address: _address, locationName: _locationName, latitude: _latitude, longitude: _longitude, description: _description, attendees: _attendees, host: _host, status: .accepted)
let testEventDeclined = Event(UID: UUID().uuidString, eventName: _eventName, startDatetime: _startDatetime, endDatetime: _endDatetime, address: _address, locationName: _locationName, latitude: _latitude, longitude: _longitude, description: _description, attendees: _attendees, host: _host, status: .declined)
let testEventActive = Event(UID: UUID().uuidString, eventName: _eventName, startDatetime: _startDatetime, endDatetime: _endDatetime, address: _address, locationName: _locationName, latitude: _latitude, longitude: _longitude, description: _description, attendees: _attendees, host: _host, status: .active)
let testEventExpired1 = Event(UID: UUID().uuidString, eventName: _eventName, startDatetime:  _pastStartDatetime, endDatetime: _pastEndDatetime, address: _address, locationName: _locationName, latitude: _latitude, longitude: _longitude, description: _description, attendees: _attendees, host: _host, status: .accepted)
let testEventExpired2 = Event(UID: UUID().uuidString, eventName: _eventName, startDatetime: _pastStartDatetime, endDatetime: _pastEndDatetime, address: _address, locationName: _locationName, latitude: _latitude, longitude: _longitude, description: _description, attendees: _attendees, host: _host, status: .active)
