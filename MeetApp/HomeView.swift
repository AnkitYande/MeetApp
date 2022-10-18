//
//  ContentView.swift
//  MeetAppTesting
//
//  Created by Ankit Yande on 10/16/22.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack{
                Spacer()
                ScrollView {
                    VStack{
                        VStack{
                            headdingButtons()
                                .padding(.top, 30.0)
                            Spacer()
                            Text("Happening Now!")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)
                            card(title: "Party at Bo's", date: "October 31st", time: "7:30pm", address:"123 Bo Street, Austin, TX")
                                .padding()
                        }
                        .background(Color.purple)
                        
                        Spacer()
                        Text("Future Events")
                            .font(.title2)
                            .fontWeight(.bold)
                        LazyVStack(){
                            card(title: "Party at Bo's", date: "October 31st", time: "7:30pm", address:"123 Bo Street, Austin, TX")
                            card(title: "Party at Bo's", date: "October 31st", time: "7:30pm", address:"123 Bo Street, Austin, TX")
                            card(title: "Party at Bo's", date: "October 31st", time: "7:30pm", address:"123 Bo Street, Austin, TX")
                        }.padding()
                    }
                }
                .edgesIgnoringSafeArea(.top)
                
                addBtn()
            }
        }
    }
}

struct headdingButtons: View{
    var body: some View{
        HStack{
            Image(systemName: "gearshape")
                .padding()
                .background(Color.white)
                .foregroundColor(Color.purple)
                .clipShape(Circle())
                .padding()
            Spacer()
            Image(systemName: "person.3")
                .padding()
                .background(Color.white)
                .foregroundColor(Color.purple)
                .clipShape(Circle())
                .padding()
        }
    }
}

struct addBtn: View{
    var body: some View{
        VStack{
            Spacer()
            HStack{
                Spacer()
//                NavigationLink(destination: CreateMeetingView()){
                    Image(systemName: "plus")
                        .font(.system(size:24, weight: .bold))
                        .padding()
                        .foregroundColor(Color.white)
                        .background(Color.purple)
                        .clipShape(Circle())
//                }
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct card: View{
    var title:String
    var date:String
    var time:String
    var address:String
    
    var body: some View{
        VStack(alignment: .leading){
            Text(title)
                .fontWeight(.bold)
            Text(date)
            Text(time)
            Text(address)
            HStack{
                Spacer()
                cta(text: "Accept")
                Spacer()
                cta(text: "Decline")
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

public struct cta: View{
    
    var text:String
    
    public var body: some View{
        Button(text, action: action)
            .frame(minWidth: 64)
            .padding()
            .background(Color.purple)
            .foregroundColor(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 100))
            .clipShape(RoundedRectangle(cornerRadius: 100))
    }
}

func action() {
    print("pressed")
    return
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

