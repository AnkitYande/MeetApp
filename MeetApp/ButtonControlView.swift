//
//  ButtonControlView.swift
//  MeetApp
//
//  Created by Ankit Yande on 11/4/22.
//

import SwiftUI

struct ButtonControlView: View {
    
    let buttonState:EventState
    
    var body: some View {
        switch buttonState {
        case .accepted:  accepted()
        case .declined:  declined()
        case .active:  acceptDecline()
        case .expired:  expired()
        }
    }
}

struct acceptDecline: View {
    public var body: some View {
        HStack{
            Spacer()
            cta(text: "Accept", minWidth: 64, bgColor: Color.purple, action: changeToAccepted)
            Spacer()
            cta(text: "Decline", minWidth: 64, bgColor: Color.purple, action: changeToDeclined)
            Spacer()
        }
    }
}

struct accepted: View {
    public var body: some View {
        HStack{
            Spacer()
            cta(text: "Accepted", minWidth: 128, bgColor: Color.purple, action: changeToActive)
            Spacer()
        }
    }
}

struct declined: View {
    public var body: some View {
        HStack{
            Spacer()
            cta(text: "Declined", minWidth: 128, bgColor: Color.purple, action: changeToActive)
            Spacer()
        }
    }
}

struct expired: View {
    public var body: some View {
        HStack{
            Spacer()
            cta(text: "Expired", minWidth: 128, bgColor: Color.gray, action: changeToActive)
            Spacer()
        }
    }
}

func action() -> Void {
    print("pressed")
}
func changeToAccepted() -> Void {
    print("pressed")
}
func changeToDeclined() -> Void {
    print("Set state to declined in DB")
}
func changeToActive() -> Void {
    print("Set state to active in DB")
}

struct ButtonControlView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonControlView(buttonState: .declined)
    }
}


