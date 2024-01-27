//
//  LandingPage.swift
//
//
//  Created by Evan Crow on 1/26/24.
//

import SwiftUI

struct LandingPage: View {
    var body: some View {
        SectionPage(italicTitle: "", titleEnd: "") {
            VStack(spacing: 52) {
                VStack {
                    if #available(iOS 16.0, *) {
                        Group {
                            Text("Welcome to the")
                            + Text(" new")
                                .italic()
                            + Text(" Oculi")
                        }
                        .font(.title)
                        .fontWeight(.semibold)
                    }
                    
                    Text("VERSION 2")
                        .font(.caption)
                }
                
                VStack(spacing: 16) {
                    Button {
                        
                    } label: {
                        Text("Get Started")
                    }.buttonStyle(FilledButtonStyle())
                    
                    Button {
                        
                    } label: {
                        Text("Revisit the Old Oculi")
                            .italic()
                            .underline()
                    }
                }
            }
        }
    }
}

#Preview {
    LandingPage()
}
