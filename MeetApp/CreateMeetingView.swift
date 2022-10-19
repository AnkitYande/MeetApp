//
//  CreateMeetingView.swift
//  MeetAppTesting
//
//  Created by Ankit Yande on 10/17/22.
//

import SwiftUI


struct CreateMeetingView: View {
    
    @State private var meetingName: String = ""
    @State private var meetingDescription: String = ""

    var body: some View {
        ScrollView {
            Text("Create a meeting")
                .font(.title)
                .fontWeight(.bold)
            VStack(alignment: .leading){
                TextField("Meeting Name", text: $meetingName)
                    .textFieldStyle(.plain)
                    .font(.title).fontWeight(.semibold)
                Text("Where").font(.title3).fontWeight(.semibold)
                Text("[Search for a location Button]")
                Text("When").font(.title3).fontWeight(.semibold)
                Text("[Calendar Picker]")
                Text("Who").font(.title3).fontWeight(.semibold)
                Text("[Friend/ Group Picker]")
                Text("Why").font(.title3).fontWeight(.semibold)
                TextField("Enter a description of your meeting here", text: $meetingDescription, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
            }.padding()
            cta(text:"Create Meeting")
        }
    }
}

struct CreateMeetingView_Previews: PreviewProvider {
    static var previews: some View {
        CreateMeetingView()
    }
}
