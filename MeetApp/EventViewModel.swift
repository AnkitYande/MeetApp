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
                    let eventDict = snapshot?.value as? [String: Any] ?? [String: Any]();
                    
                    let eventName = eventDict["eventName"] as! String
                    let location = eventDict["location"] as! String
                    let latitude = eventDict["latitude"] as! Double
                    let longitude = eventDict["longitude"] as! Double
                    let startDatetime = eventDict["startDatetime"] as! String
                    let endDatetime = eventDict["endDatetime"] as! String
                    let description = eventDict["description"] as! String
                    let host = eventDict["host"] as! String
                    
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
                    
                    let newEvent = Event(UID: eventUUID, eventName: eventName, startDatetime: startDatetime, endDatetime: endDatetime, address: location, latitude: latitude, longitude: longitude, description: description, attendees: attendeesList.joined(separator: ", "), host: host, status: .active)
                        self.events.append(newEvent)
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
                    let eventDict = snapshot?.value as? [String: Any] ?? [String: Any]();
                    
                    let eventName = eventDict["eventName"] as! String
                    let location = eventDict["location"] as! String
                    let latitude = eventDict["latitude"] as! Double
                    let longitude = eventDict["longitude"] as! Double
                    let startDatetime = eventDict["startDatetime"] as! String
                    let endDatetime = eventDict["endDatetime"] as! String
                    let description = eventDict["description"] as! String
                    let host = eventDict["host"] as! String
                    
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
                    
                    let newEvent = Event(UID: eventUUID, eventName: eventName, startDatetime: startDatetime, endDatetime: endDatetime, address: location, latitude: latitude, longitude: longitude, description: description, attendees: attendeesList.joined(separator: ", "), host: host, status: .accepted)
                        self.events.append(newEvent)
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
                    let eventDict = snapshot?.value as? [String: Any] ?? [String: Any]();
                    
                    let eventName = eventDict["eventName"] as! String
                    let location = eventDict["location"] as! String
                    let latitude = eventDict["latitude"] as! Double
                    let longitude = eventDict["longitude"] as! Double
                    let startDatetime = eventDict["startDatetime"] as! String
                    let endDatetime = eventDict["endDatetime"] as! String
                    let description = eventDict["description"] as! String
                    let host = eventDict["host"] as! String
                    
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
                    
                    let newEvent = Event(UID: eventUUID, eventName: eventName, startDatetime: startDatetime, endDatetime: endDatetime, address: location, latitude: latitude, longitude: longitude, description: description, attendees: attendeesList.joined(separator: ", "), host: host, status: .declined)
                        self.events.append(newEvent)
                })
            }
        })
    }
}
