//
//  Util.swift
//  MeetApp
//
//  Created by Ankit Yande on 10/28/22.
//

import Foundation

public struct Event : Identifiable{
    public var id = UUID() //replace with Firebase ID
    var eventName:String
    var startDatetime:String
    var endDatetime:String
    var address:String
    var description:String
    var attendees:String
    var host:String
}

public func formatDate(datetimeString:String) -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    let date = dateFormatter.date(from: datetimeString)!
    dateFormatter.dateStyle = .long
    return dateFormatter.string(from: date)
}

public func formatTime(datetimeString:String) -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    let date = dateFormatter.date(from: datetimeString)!
    dateFormatter.timeStyle = .short
    return dateFormatter.string(from: date)
}
