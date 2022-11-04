//
//  ContentView.swift
//  MeetAppTesting
//
//  Created by Ankit Yande on 10/16/22.
//

import SwiftUI  

var _eventName:String = "Party at Bo's"
var _startDatetime:String = "2022-10-30 22:00:00 +0000"
var _endDatetime:String = "2022-10-31 22:26:00 +0000"
var _address = "123 West Campus Street"
var _description:String = "Bo is throwing the most popping party in all of Wampus! Come on through for this great networking opportunity"
var _attendees:String = ""
var _host:String = "Bo Deng"

public var testEvent = Event(eventName: _eventName, startDatetime: _startDatetime, endDatetime: _endDatetime, address: _address, description: _description, attendees: _attendees, host: _host)

struct HomeView: View {
    
    @State public var shown = false
    @State var isSuccess = false
    @State var alertType:modalType = .accept
    
    var body: some View {
        NavigationView {
            ZStack{
                ZStack{
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
                                card(event: testEvent, action: action)
                                    .padding(.leading).padding(.trailing)
                            }
                            .background(Color.purple)
                            Spacer()
                            Text("Future Events")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.top, 24.0)
                            LazyVStack(){
                                // replace with loadinf from API
                                ForEach(1...4, id:\.self) { event in
                                    card(event: testEvent, action: action)
                                }
                            }.padding(.leading).padding(.trailing)
                        }
                    }
                    .edgesIgnoringSafeArea(.top)
                    addBtn()
                }
                .overlay {
                    Color(white: 0, opacity: shown ? 0.75 : 0)
                        .edgesIgnoringSafeArea(.all)
                }.onTapGesture() {
                    withAnimation(Animation.spring()) {
                        shown.toggle()
                    }
                }
                ModalView(style: alertType)
                    .opacity(shown ? 1: 0)
            }
        }
    }
    
    func action() -> Void {
        withAnimation(Animation.spring()) {
            shown.toggle()
        }
        print("pressed")
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
    var action: ()->Void
    
    var body: some View{
        NavigationLink(destination: EventView(event: testEvent)){
            VStack(alignment: .leading){
                Text(event.eventName)
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
                Text("\(formatDate(datetimeString: event.startDatetime))").foregroundColor(Color.black)
                Text("\(formatTime(datetimeString: event.startDatetime))").foregroundColor(Color.black)
                Text(event.address).foregroundColor(Color.black)
                HStack{
                    Spacer()
                    cta(text: "Accept", minWidth: 64, action: action)
                    Spacer()
                    cta(text: "Decline", minWidth: 64, action: action)
                    Spacer()
                }
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.gray, radius: 4)
            .padding()
        }
    }
}

public struct cta: View{
    
    var text:String
    var minWidth:CGFloat
    var action: ()->Void
    
    public var body: some View {
        Button(text, action: action)
            .frame(minWidth: minWidth)
            .padding()
            .background(Color.purple)
            .foregroundColor(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 100))
            .clipShape(RoundedRectangle(cornerRadius: 100))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

