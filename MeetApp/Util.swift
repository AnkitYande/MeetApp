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
    var UID = UUID() //replace with firebase UID
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
    
    init(eventName: String, startDatetime: String, endDatetime: String, address: String, latitude: Double, longitude: Double, description: String, attendees: String, host: String, status: EventState) {
        self.eventName = eventName
        self.startDatetime = convertStringToDate(datetimeString: startDatetime)
        self.endDatetime = convertStringToDate(datetimeString: endDatetime)
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.description = description
        self.attendees = attendees
        self.host = host
        if( Date.now > self.endDatetime){
            self.status = .expired
        }else{
            self.status = status
        }
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
