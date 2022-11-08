//
//  Util.swift
//  MeetApp
//
//  Created by Ankit Yande on 10/28/22.
//

import Foundation

public enum EventState {
    case accepted, declined, active, expired
}

public class Event: Identifiable {
    var UID: String
    var eventName:String
    var startDatetime:Date
    var endDatetime:Date
    var address:String
    var latitude:Double
    var longitude:Double
    var description:String
    var attendees:String
    var host:String
    var status:EventState
    
    init(UID: String, eventName: String, startDatetime: String, endDatetime: String, address: String, latitude: Double, longitude: Double, description: String, attendees: String, host: String, status: EventState) {
        self.UID = UID
        self.eventName = eventName
        self.startDatetime = convertStringToDate(datetimeString: startDatetime)
        self.endDatetime = convertStringToDate(datetimeString: endDatetime)
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.description = description
        self.attendees = attendees
        self.host = host
        if (Date.now > self.endDatetime) {
            self.status = .expired
        } else{
            self.status = status
        }
    }
}

public class User: Identifiable {
    var UID: String
    var email: String
    var displayName: String
    var username: String
    var profilePic: String
    var status: String
    var latitude: Double
    var longitude: Double
//    var friends: [User]
    var eventsInvited: [String]
    var eventsHosting: [String]
//    var eventsAccepted: [Event]
//    var eventsDeclined: [Event]
    
    init(UID: String, email: String, displayName: String, username: String, profilePic: String, status: String, latitude: Double, longitude: Double, eventsInvited: [String], eventsHosting: [String]) {
        self.UID = UID
        self.email = email
        self.displayName = displayName
        self.username = username
        self.profilePic = profilePic
        self.status = status
        self.latitude = latitude
        self.longitude = longitude
//        self.friends = friends
        self.eventsInvited = eventsInvited
        self.eventsHosting = eventsHosting
//        self.eventsAccepted = eventsAccepted
//        self.eventsDeclined = eventsDeclined
    }
}

func convertStringToDate(datetimeString:String) -> Date{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    let date = dateFormatter.date(from: datetimeString)!
    return date
}

func formatDate(_ date:Date) -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    return dateFormatter.string(from: date)
}

func formatTime(_ date:Date) -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = .short
    return dateFormatter.string(from: date)
}
