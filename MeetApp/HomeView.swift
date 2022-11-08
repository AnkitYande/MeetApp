//
//  ContentView.swift
//  MeetAppTesting
//
//  Created by Ankit Yande on 10/16/22.
//

import SwiftUI
import FirebaseDatabase

struct HomeView: View {
    @StateObject private var eventViewModel = EventViewModel(userUUID: user_id)
    @StateObject private var userViewModel = UserViewModel(userUUID: user_id)

    var body: some View {
        NavigationView {
            ZStack{
                Spacer()
                ScrollView {
                    VStack{
                        VStack{
                            headdingButtons().padding(.top, 40.0)
                            Spacer()
                            Text("Happening Now!")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)
                            if eventViewModel.currentEvents.count > 0 {
                                LazyVStack(){
                                    ForEach(eventViewModel.currentEvents, id:\.UID) { event in
                                        card(event: event)
                                    }
                                }.padding(.leading).padding(.trailing)
                            }else{
                                Text("No events currently happening. Press the plus button the schedule an event!")
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40.0)
                                    .padding(.vertical, 24.0)
                            }
                        }
                        .background(Color.purple)
                        Spacer()
                        
                        Text("Future Events")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 24.0)
                        if eventViewModel.activeEvents.count > 0 {
                            LazyVStack(){
                                ForEach(eventViewModel.activeEvents, id:\.UID) { event in
                                    card(event: event)
                                }
                            }.padding(.leading).padding(.trailing)
                        }else{
                            Text("No future events")
                        }
                        
                        Text("Declined Events")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 24.0)
                        if eventViewModel.declinedEvents.count > 0 {
                            LazyVStack(){
                                ForEach(eventViewModel.declinedEvents, id:\.UID) { event in
                                    card(event: event)
                                }
                            }.padding(.leading).padding(.trailing)
                        }else{
                            Text("No declined events")
                        }
                        
                        Text("Expired Events")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 24.0)
                        if eventViewModel.expiredEvents.count > 0 {
                            LazyVStack(){
                                ForEach(eventViewModel.expiredEvents, id:\.UID) { event in
                                    card(event: event)
                                }
                            }.padding(.leading).padding(.trailing)
                        }else{
                            Text("No expired events")
                        }
                    }
                }
                .edgesIgnoringSafeArea(.top)
                
                addBtn()
            }.onAppear {
                eventViewModel.getEvents()
                userViewModel.getAllUsers()
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
                Text(event.address.components(separatedBy: ",")[0])
                    .foregroundColor(Color.black)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

