//
//  EventView.swift
//  MeetApp
//
//  Created by Ankit Yande on 10/28/22.
//

import SwiftUI

struct EventView: View {
    
    let event:Event
    
    var body: some View {
        
        
        ScrollView {
            VStack(alignment: .leading){
                Text(event.eventName).font(.title).fontWeight(.semibold).padding(.top, 12.0)
                Group{
                    Text("Details").font(.title3).fontWeight(.semibold).padding(.top, 12.0)
                    HStack {
                        Image(systemName: "calendar").padding([.top, .trailing], 5.0).font(Font.title3.weight(.medium))
                        Text("\(formatDates(event.startDatetime,event.endDatetime))")
                    }
                    HStack {
                        Image(systemName: "clock").padding([.top, .trailing], 5.0).font(Font.title3.weight(.medium))
                        Text("\(formatTime(datetimeString: event.startDatetime)) - \(formatTime(datetimeString: event.endDatetime))")
                    }
                    HStack {
                        Image(systemName: "mappin.and.ellipse").padding([.top, .trailing], 5.0).font(Font.title3.weight(.medium))
                        Text(event.address)
                    }
                    Text("Description").font(.title3).fontWeight(.semibold).padding(.top, 24.0)
                    Text(event.description)
                }
                Text("Map").font(.title3).fontWeight(.semibold).padding(.top, 24.0)
                Text("<Insert Map Here>")
                Text("Guests").font(.title3).fontWeight(.semibold).padding(.top, 24.0)
                Text("<Insert Social List Here>")
            }.padding()
        }
    }
}

func formatDates( _ datetimeString1:String, _ datetimeString2:String) -> String {
    // do not show a date if the event begins and ends on the same day
    let d1 = formatDate(datetimeString: datetimeString1)
    let d2 = formatDate(datetimeString: datetimeString2)
    return d1 == d2 ? d1 : "\(d1) - \(d2)"
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(event: testEvent)
    }
}
