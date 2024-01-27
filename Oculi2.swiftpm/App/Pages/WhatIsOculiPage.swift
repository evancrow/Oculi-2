//
//  WhatIsOculiPage.swift
//
//
//  Created by Evan Crow on 1/26/24.
//

import SwiftUI

struct WhatIsOculiPage: View {
    var body: some View {
        SectionPage(italicTitle: "What is", titleEnd: "Oculi?") {
            HStack {
                Text("I invented Oculi to make it easier for everyday people with motor-disabilites to use their Apple Devices. In Version 1, I made it possible to navigate SwiftUI apps using only your head and eyes.")
                
                Spacer()
            }
            
            HStack {
                Text("With this release of Version 2, it is now possible to use your hands from a distance. Unable to get up to reach your device? Wave your hand to scroll, tap, and zoom.")
                
                Spacer()
            }
            
            Button {
                
            } label: {
                Text("Get Started")
            }.buttonStyle(FilledButtonStyle())
        }
    }
}

#Preview {
    WhatIsOculiPage()
}
