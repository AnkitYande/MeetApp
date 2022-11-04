//
//  CommonUI.swift
//  MeetApp
//
//  Created by Ankit Yande on 11/4/22.
//

import SwiftUI

public struct cta: View{
    
    var text:String
    var minWidth:CGFloat
    var bgColor:Color
    var action: () -> Void
    
    public var body: some View {
        Button(text, action: action)
            .fontWeight(.semibold)
            .frame(minWidth: minWidth)
            .padding()
            .background(bgColor)
            .foregroundColor(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 100))
            .clipShape(RoundedRectangle(cornerRadius: 100))
    }
}
