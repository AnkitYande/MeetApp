//
//  ContentView.swift
//  MeetAppTesting
//
//  Created by Ankit Yande on 10/16/22.
//

import SwiftUI


// Temp for TESTING
// replace with loading from API
var _eventName:String = "Party at Bo's"
var _pastStartDatetime:String = "2022-10-30 22:00:00 +0000"
var _pastEndDatetime:String = "2022-10-31 22:26:00 +0000"
var _startDatetime:String = "2023-10-30 22:00:00 +0000"
var _endDatetime:String = "2023-10-31 22:26:00 +0000"
var _address:String = "2111 Rio Grande St, Austin, TX 78705"
var _latitude:Double = 30.284680
var _longitude:Double = -97.744940
var _description:String = "Bo is throwing the most popping party in all of Wampus!  Come on through for this great networking opportunity"
var _attendees:String = ""
var _host:String = "Bo Deng"
public var testEventConfirmed = Event(eventName: _eventName, startDatetime: _startDatetime, endDatetime: _endDatetime, address: _address, latitude: _latitude, longitude: _longitude, description: _description, attendees: _attendees, host: _host, status: .accepted)
public var testEventDeclined = Event(eventName: _eventName, startDatetime: _startDatetime, endDatetime: _endDatetime, address: _address,latitude: _latitude, longitude: _longitude, description: _description, attendees: _attendees, host: _host, status: .declined)
public var testEventActive = Event(eventName: _eventName, startDatetime: _startDatetime, endDatetime: _endDatetime, address: _address, latitude: _latitude, longitude: _longitude, description: _description, attendees: _attendees, host: _host, status: .active)
public var testEventExpired1 = Event(eventName: _eventName, startDatetime:  _pastStartDatetime, endDatetime: _pastEndDatetime, address: _address, latitude: _latitude, longitude: _longitude, description: _description, attendees: _attendees, host: _host, status: .accepted)
public var testEventExpired2 = Event(eventName: _eventName, startDatetime: _pastStartDatetime, endDatetime: _pastEndDatetime, address: _address, latitude: _latitude, longitude: _longitude, description: _description, attendees: _attendees, host: _host, status: .active)
let eventTestArr = [testEventConfirmed,testEventDeclined,testEventActive,testEventExpired1,testEventExpired2]


struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack{
                Spacer()
                ScrollView {
                    VStack{
                        VStack{
                            headdingButtons()
                                .padding(.top, 32.0)
                            Spacer()
                            Text("Happening Now!")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)
                            card(event: testEventActive).padding(.leading).padding(.trailing)
                        }
                        .background(Color.purple)
                        Spacer()
                        Text("Future Events")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 24.0)
                        LazyVStack(){
                            ForEach(eventTestArr, id:\.UID) { event in
                                card(event: event)
                            }
                        }.padding(.leading).padding(.trailing)
                    }
                }
                .edgesIgnoringSafeArea(.top)
                
                addBtn()
            }
        }
    }
}

struct SettingsView: UIViewControllerRepresentable {
    typealias UIViewControllerType = SettingsViewController
    
    func makeUIViewController(context: Context) -> SettingsViewController {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let viewController = sb.instantiateViewController(identifier: "SettingsViewController") as! SettingsViewController
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: SettingsViewController, context: Context) {
        
    }
}

struct SocialView: UIViewControllerRepresentable {
    typealias UIViewControllerType = SocialViewController
    
    func makeUIViewController(context: Context) -> SocialViewController {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let viewController = sb.instantiateViewController(identifier: "SocialViewController") as! SocialViewController
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: SocialViewController, context: Context) {
        
    }
}

struct headdingButtons: View{
    var body: some View{
        HStack{
            NavigationLink(destination:SettingsView()){
                Image(systemName: "gearshape")
                    .padding()
                    .background(Color.white)
                    .foregroundColor(Color.purple)
                    .clipShape(Circle())
                    .padding()
            }
            Spacer()
            NavigationLink(destination:SocialView()){
                Image(systemName: "person.3")
                    .padding()
                    .background(Color.white)
                    .foregroundColor(Color.purple)
                    .clipShape(Circle())
                    .padding()
            }
        }
    }
}

struct addBtn: View{
    var body: some View{
        VStack{
            Spacer()
            HStack{
                Spacer()
                NavigationLink(destination: CreateEventView()){
                    Image(systemName: "plus")
                        .font(.system(size:24, weight: .bold))
                        .padding()
                        .foregroundColor(Color.white)
                        .background(Color.purple)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct card: View{
    var event:Event
    
    var body: some View{
        NavigationLink(destination: EventView(event: event)){
            VStack(alignment: .leading){
                Text(event.eventName)
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
                Text("\(formatDate(event.startDatetime))").foregroundColor(Color.black)
                Text("\(formatTime(event.startDatetime))").foregroundColor(Color.black)
                Text(event.address).foregroundColor(Color.black)
                ButtonControlView(buttonState: event.status)
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.gray, radius: 4)
            .padding()
        }
    }
}

//func action() -> Void {
//    print("pressed")
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

