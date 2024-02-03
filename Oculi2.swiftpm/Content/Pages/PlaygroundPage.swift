//
//  PlaygroundPage.swift
//
//
//  Created by Evan Crow on 1/28/24.
//

import SwiftUI

enum PlaygroundStep {
    case playground
    case developers
    case evanCrow
    
    var title: String {
        switch self {
        case .playground:
            "Playground"
        case .developers:
            "How Developers Use Oculi"
        case .evanCrow:
            "Evan Crow"
        }
    }

    var subtitle: String {
        switch self {
        case .playground:
            "Here you can try interacting with different elements."
        case .developers:
            "This is how developers (or Apple) can add Oculi to their SwiftUI applications."
        case .evanCrow:
            "Behind the creator."
        }
    }
}

struct PlaygroundPage: View {
    @EnvironmentObject var navigationModel: NavigationModel
    @State var step: PlaygroundStep = .playground

    var body: some View {
        PageContainer {
            VStack(spacing: PaddingSizes._52) {
                VStack(spacing: PaddingSizes._52) {
                    VStack(spacing: PaddingSizes._6) {
                        Text(step.title)
                            .font(FontStyles.Title.font)

                        Text(step.subtitle)
                            .font(FontStyles.Body.font)
                    }
                    
                    switch step {
                    case .playground:
                        TextSection(
                            header: "Thank You",
                            text:
                                "This is the last page of the Oculi demo. Thank you for trying it out, I appreciate your time and consideration!"
                        )

                        TextSection(
                            header: "Tip",
                            text:
                                "You can always re-calibrate or restart the tutorial by tapping the options at the bottom of the page."
                        )
                    case .developers:
                        EmptyView()
                    case .evanCrow:
                        EmptyView()
                    }
                }

                Spacer()
              
                VStack(spacing: PaddingSizes._12) {
                    HStack(spacing: PaddingSizes._32) {
                        SegmentedPicker(options: [
                            .init(label: "Playground") {
                                step = .playground
                            },
                            .init(label: "How Developers Use Oculi") {
                                step = .developers
                            },
                            .init(label: "Evan Crow") {
                                step = .evanCrow
                            },
                        ])
                        
                        SegmentedPicker(
                            showSelected: false,
                            options: [
                                .init(label: "Calibrate") {
                                    navigationModel.stack(page: .Calibrate)
                                },
                                .init(label: "Tutorial") {
                                    navigationModel.stack(page: .Tutorial)
                                },
                            ]
                        )
                    }.fixedSize()
                    
                    Text("Tap or Swipe Between Pages")
                        .font(FontStyles.Body2.font)
                }
            }
        }
    }
}

#Preview {
    PlaygroundPage(step: .playground)
}

#Preview {
    PlaygroundPage(step: .developers)
}

#Preview {
    PlaygroundPage(step: .evanCrow)
}
