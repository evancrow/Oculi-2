//
//  TutorialPage.swift
//  
//
//  Created by Evan Crow on 1/28/24.
//

import MapKit
import SwiftUI

enum TutorialStep: String {
    case panning = "Panning"
    case tapping = "Tapping"
    case scrolling = "Scrolling"
    case zooming = "Zooming"
}

struct TutorialPage: View {
    @EnvironmentObject var navigationModel: NavigationModel
    @State var step: TutorialStep = .tapping
    
    var title: String {
        step.rawValue
    }
    
    var subtitle: String {
        switch step {
        case .tapping:
            "Point your finger to move an on screen cursor. Then press in to tap."
        case .panning:
            "To move around the map below, try swiping your hand in different ways."
        case .scrolling:
            "Use two fingers to scroll up and down."
        case .zooming:
            "Pinch in and out to zoom."
        }
    }
    
    var nextStep: Text {
        switch step {
        case .tapping, .scrolling:
            return Text("To move on, tap ") + Text("Next Page.").italic()
        case .panning:
            return Text("Oculi will automatically move to the next page after interacting with the map.")
        case .zooming:
            return Text("To finish the tutorial, tap ") + Text("Finish Tutorial.").italic()
        }
    }
    
    @ViewBuilder
    var content: some View {
        switch step {
        case .tapping:
            VStack(spacing: PaddingSizes._52) {
                Button {
                    
                } label: {
                    Text("Button 1")
                }
                
                Button {
                    
                } label: {
                    Text("Button 1")
                }
                
                Button {
                    step = .panning
                } label: {
                    Text("Next Page")
                }
            }.buttonStyle(DefaultButtonStyle())
        case .panning:
            Color.gray
                .frame(maxWidth: 600, idealHeight: 300)
        case .scrolling:
            VStack(spacing: PaddingSizes._52) {
                ScrollView {
                    LinearGradient(colors: [.blue, .red], startPoint: .top, endPoint: .bottom)
                        .frame(maxWidth: .infinity, idealHeight: 1000)
                }
                
                Button {
                    step = .zooming
                } label: {
                    Text("Next Page")
                }.buttonStyle(DefaultButtonStyle())
            }
        case .zooming:
            VStack(spacing: PaddingSizes._52) {
                Color.gray
                    .frame(maxWidth: 600, idealHeight: 300)
                
                VStack(spacing: PaddingSizes._12) {
                    Button {
                        navigationModel.moveToNextPage(popFirst: true)
                    } label: {
                        Text("Finish Tutorial")
                    }.buttonStyle(DefaultButtonStyle())
                    
                    Button {
                        step = .tapping
                    } label: {
                        Text("Restart")
                    }.buttonStyle(UnderlinedButtonStyle())
                }
            }
        }
    }
    
    var body: some View {
        PageContainer {
            VStack(spacing: PaddingSizes._52) {
                VStack(spacing: PaddingSizes._6) {
                    Text(title)
                        .font(FontStyles.Title.font)
                    
                    Text(subtitle)
                        .font(FontStyles.Body.font)
                    
                    nextStep
                        .font(FontStyles.Body.font)
                }
                
                content
                
                Button {
                    navigationModel.moveToNextPage(popFirst: true)
                } label: {
                    Text("Skip")
                }.buttonStyle(UnderlinedButtonStyle())
            }
        }
    }
}

#Preview {
    TutorialPage(step: .tapping)
}

#Preview {
    TutorialPage(step: .panning)
}

#Preview {
    TutorialPage(step: .scrolling)
}

#Preview {
    TutorialPage(step: .zooming)
}
