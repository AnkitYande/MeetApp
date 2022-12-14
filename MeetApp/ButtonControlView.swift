//
//  ButtonControlView.swift
//  MeetApp
//
//  Created by Ankit Yande on 11/4/22.
//

import SwiftUI
import CoreData
import FirebaseDatabase

extension Date {
    func subtractHours(_ hours: Int) -> Date {
        let seconds: TimeInterval = Double(hours) * 60 * 60
        let newDate: Date = self.addingTimeInterval(-seconds)
        return newDate
    }
    
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}

struct ButtonControlView: View {
    
    let event:Event
    var eventViewModel:EventViewModel
    @Binding var eventList: [Event]
    
    var body: some View {
        switch event.status {
        case .accepted:  accepted(event: event, eventViewModel: eventViewModel)
        case .declined:  declined(event: event, eventViewModel: eventViewModel)
        case .active:  acceptDecline(event: event, eventViewModel: eventViewModel)
        case .expired:  expired()
        case .current: otw(event: event)
        }
    }
}

struct acceptDecline: View {
    var event:Event
    var eventViewModel:EventViewModel
    
    public var body: some View {
        HStack{
            Spacer()
            cta(text: "Accept", minWidth: 64, bgColor: Color.purple, action: {
                changeEventStatus(eventID: event.UID, currentStatus: "Invited", newStatus: "Accepted", newState: EventState.accepted, eventViewModel:eventViewModel)
                
            })
            Spacer()
            cta(text: "Decline", minWidth: 64, bgColor: Color.purple, action: {
                changeEventStatus(eventID: event.UID, currentStatus: "Invited", newStatus: "Declined", newState: EventState.declined, eventViewModel:eventViewModel)
            })
            Spacer()
        }
    }
}

struct accepted: View {
    var event:Event
    var eventViewModel:EventViewModel
    
    public var body: some View {
        HStack{
            Spacer()
            cta(text: "Accepted", minWidth: 128, bgColor: Color.purple, action: {
                changeEventStatus(eventID: event.UID, currentStatus: "Accepted", newStatus: "Invited", newState: EventState.active, eventViewModel:eventViewModel)
            })
            Spacer()
        }
    }
}

struct declined: View {
    var event:Event
    var eventViewModel:EventViewModel
    
    public var body: some View {
        HStack{
            Spacer()
            cta(text: "Declined", minWidth: 128, bgColor: Color.purple, action: {
                changeEventStatus(eventID: event.UID, currentStatus: "Declined", newStatus: "Invited", newState: EventState.active, eventViewModel:eventViewModel)
            })
            Spacer()
        }
    }
}

struct expired: View {
    public var body: some View {
        HStack{
            Spacer()
            cta(text: "Expired", minWidth: 128, bgColor: Color.gray, action: disabledFunc)
            Spacer()
        }
    }
}

struct otw: View {
    let event: Event
    
    @State private var showingAlert = false
    @State private var locationFlags = UserDefaults.standard.array(forKey: "locationFlags") as? [String] ?? []
    
    @State private var location: String = ""
    @State private var locationName: String = ""
    @State private var latitude: Double = 0.0
    @State private var longitude: Double = 0.0
    
    public var body: some View {
        if (locationFlags.contains(event.UID)){
            HStack{
                Spacer()
                NavigationLink(destination: MapView(location: $location, locationName: $locationName, latitude: $latitude, longitude: $longitude, eventMap: true, eventName: event.eventName, eventID: event.UID)) {
                    Text("See Map")
                }
                .fontWeight(.semibold)
                .frame(minWidth: 128)
                .padding()
                .background(Color.purple)
                .foregroundColor(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 100))
                .clipShape(RoundedRectangle(cornerRadius: 100))
                Spacer()
            }.onAppear {
                setLocation()
            }
        } else {
            HStack{
                Spacer()
                cta(text: "On The Way!", minWidth: 128, bgColor: Color.purple, action: toggleAlert)
                    .alert( "On your way?", isPresented: $showingAlert){
                        Button(action: shareLocation) { Text("Confirm") }
                        Button("Cancle", role: .cancel) { }
                    } message: {
                        Text("Pressing confirm will allow everyone in your event be able to see your location until the event ends")
                    }
                Spacer()
            }
        }
    }
    
    func setLocation() -> Void {
        location = event.address
        locationName = event.locationName
        latitude = event.latitude
        longitude = event.longitude
        //        print("Location has been set to: \(location). \nLAT: \(latitude)\tLON: \(longitude)")
    }
    
    func toggleAlert() -> Void{
        self.showingAlert = !self.showingAlert
    }
    
    func shareLocation(){
        locationFlags.append(event.UID)
        UserDefaults.standard.set(locationFlags, forKey: "locationFlags")
        let timeDelta = event.endDatetime + 3600 - Date()
        print("removing flag in", timeDelta)
        DispatchQueue.main.asyncAfter(deadline: .now() + timeDelta) {
            print("EVENT EXPIRED")
            print(locationFlags)
            locationFlags.removeAll(where: {$0 == event.UID})
            print(locationFlags)
            UserDefaults.standard.set(locationFlags, forKey: "locationFlags")
        }
    }
}

func disabledFunc() -> Void {
    return
}

func mapPlaceHolder(event: Event) -> Void {
    print("Share location popup/ Navigate to full MAP")
}

func changeEventStatus(eventID:String, currentStatus:String, newStatus:String, newState:EventState, eventViewModel:EventViewModel) -> Void {
    let databaseRef = Database.database().reference()
    
    //remove event from its current status in the user object
    databaseRef.child("users").child(user_id).child("events\(currentStatus)").child(eventID).removeValue(completionBlock: { (error, refer) in
        guard error == nil else {
            print(error!.localizedDescription)
            return;
        }})
    
    //add event to its new status in the user object
    databaseRef.child("users").child(user_id).child("events\(newStatus)").child(eventID).setValue(true)
    
    //remove user from its current status in the event objext
    databaseRef.child("events").child(eventID).child("users\(currentStatus)").child(user_id).removeValue(completionBlock: { (error, refer) in
        guard error == nil else {
            print(error!.localizedDescription)
            return;
        }})
    
    //add user to its new status in the event object
    databaseRef.child("events").child(eventID).child("users\(newStatus)").child(user_id).setValue(true)
    
    let notifications = retrieveNotifications()
    let notification = notifications.first
    
    if let notificationVal = notification?.value(forKey: "checkIn") as? Int{
        // checks if user wants notifications then proceeds to send a notification an hour before the event starts
        if notificationVal == 1 {
            if newStatus == "Accepted" {
                
                let notificationContent = UNMutableNotificationContent()
                notificationContent.title = "MeetApp"
                notificationContent.subtitle = "Check In"
                notificationContent.body = "Check into your upcoming event!"
                
                databaseRef.child("events").child(eventID).child("startDatetime").getData(completion: {error, snapshot in
                    guard error == nil else {
                        print(error!.localizedDescription)
                        return;
                    }
                    let startTime = snapshot?.value as? String
                    
                    let start = convertStringToDate(datetimeString: startTime ?? "")
                    
                    let notifTime = start.subtractHours(1)
                    
                    let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
                    
                    var notifRemTime = start - Date()
                    notifRemTime -= 3600
                    if notifRemTime > 0 {
                        let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                        
                        let notificationTriggerInterval = UNTimeIntervalNotificationTrigger(timeInterval: notifRemTime, repeats: false)
                        
                        let notificationRequest = UNNotificationRequest(identifier: "checkInNotif", content: notificationContent, trigger: notificationTriggerInterval)
                        
                        let notificationCenter = UNUserNotificationCenter.current()
                        notificationCenter.add(notificationRequest) { error in
                            if error != nil {
                                print(error!.localizedDescription)
                            }
                        }
                    }
                })
            } else if newStatus == "Declined" {
                let center = UNUserNotificationCenter.current()
                center.removePendingNotificationRequests(withIdentifiers: ["checkInNotif"])
            }
        }
    }
    // update in UI
    // changing an element of the list doesn't seem to have an effect
    // copying and reassignign event list
    let eventsCopy = eventViewModel.events
    if let event = eventsCopy.first(where: {$0.UID == eventID}){
        event.setStatus(status: newState)
    }else{
        print("ERROR: event not found")
    }
    eventViewModel.events = eventsCopy
    
}

//retrieves the notifications list from core data
func retrieveNotifications() -> [NSManagedObject] {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Notifications")
    var fetchedResults: [NSManagedObject]?
    
    do {
        try fetchedResults = context.fetch(request) as? [NSManagedObject]
    } catch {
        let nserror = error as NSError
        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
        abort()
    }
    
    return (fetchedResults)!
}

