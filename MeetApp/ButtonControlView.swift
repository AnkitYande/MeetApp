//
//  ButtonControlView.swift
//  MeetApp
//
//  Created by Ankit Yande on 11/4/22.
//

import SwiftUI
import FirebaseDatabase

struct ButtonControlView: View {
    
    
    let event:Event
    var eventViewModel:EventViewModel
    @Binding var eventList: [Event] // <-- this is literally not used anymore but the code doesn't work without it??
    
    var body: some View {
        switch event.status {
        case .accepted:  accepted(event: event, eventViewModel: eventViewModel)
        case .declined:  declined(event: event, eventViewModel: eventViewModel)
        case .active:  acceptDecline(event: event, eventViewModel: eventViewModel)
        case .expired:  expired()
        case .current: otw()
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
    public var body: some View {
        HStack{
            Spacer()
            cta(text: "On The Way!", minWidth: 128, bgColor: Color.purple, action: mapPlaceHolder)
            Spacer()
        }
    }
}

func disabledFunc() -> Void {
    return
}

func mapPlaceHolder() -> Void {
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

