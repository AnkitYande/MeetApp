//
//  ModalView.swift
//  MeetApp
//
//  Created by Ankit Yande on 11/3/22.
//

import SwiftUI  

enum modalType { case accept, decline, confirm, none}

struct ModalView: View {
    
    var style:modalType
    
    var body: some View {
        
        let title: String = {
            switch style {
            case .accept: return "Accept"
            case .decline: return "Decline"
            case .confirm: return "Confirm"
            case .none: return "ERROR: No Modal Type"
            }
        }()
        
        let subtitle: String  = {
            switch style {
            case .accept: return "Are you sure you want to accept this invitation?"
            case .decline: return "Are you sure you want to decline this invitation?"
            case .confirm: return"Are you sure you want to confirm? Your friends will be able to see your location"
            case .none: return "ERROR: No Modal Type"
            }
        }()
        
        VStack(alignment: .center) {
            Spacer()
            Spacer()
            Text(title).font(.title2).fontWeight(.bold)
            Spacer()
            Text(subtitle).fontWeight(.bold).multilineTextAlignment(.center)
            Spacer()
            Spacer()
            HStack{
                HStack{
                    Spacer()
                    cta(text: "Yes", minWidth: 64, action: action)
                    Spacer()
                    cta(text: "No", minWidth: 64, action: action)
                    Spacer()
                }
            }
            Spacer()
            Spacer()
        }.padding()
        .frame(width: UIScreen.main.bounds.width-64, height: 280)
            .background(.white)
            .cornerRadius(20)
            .clipped()
        
    }
    func action() -> Void {
        print("modal btn pressed")
    }
}

struct ModalView_Previews: PreviewProvider {
    static var previews: some View {
        ModalView(style: .accept)
    }
}
