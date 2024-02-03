//
//  PlaygroundPage.swift
//
//
//  Created by Evan Crow on 1/28/24.
//

import SwiftUI

enum PlaygroundOption: String, CaseIterable {
    case calibrate = "Calibrate"
    case tutorial = "Playground"
    
    var title: String {
        self.rawValue
    }
}

enum PlaygroundStep: String, CaseIterable {
    case playground = "Playground"
    case developers = "Developers"
    case evanCrow = "Evan Crow"
    
    var title: String {
        self.rawValue
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
    @EnvironmentObject private var navigationModel: NavigationModel
    @State var step: PlaygroundStep = .playground
    @State private var selectedStep: String
    @State private var playgroundOption: String = PlaygroundOption.calibrate.rawValue

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
                        SegmentedPicker(
                            selectedOption: $selectedStep,
                            options: PlaygroundStep.allCases.map { $0.rawValue }
                        )
                        
                        SegmentedPicker(
                            selectedOption: $playgroundOption,
                            options: PlaygroundOption.allCases.map { $0.rawValue },
                            showSelected: false
                        )
                    }.fixedSize()
                    
                    Text("Tap or Swipe Between Pages")
                        .font(FontStyles.Body2.font)
                }
            }
        }.onChange(of: selectedStep) { newValue in
            switch PlaygroundStep(rawValue: newValue) {
            case .some(let newStep):
                self.step = newStep
            case .none:
                return
            }
        }.onChange(of: playgroundOption) { newValue in
            switch PlaygroundOption(rawValue: newValue) {
            case .calibrate:
                navigationModel.stack(page: .Calibrate)
            case .tutorial:
                navigationModel.stack(page: .Tutorial)
            case .none:
                return
            }
        }
    }
    
    fileprivate init(step: PlaygroundStep) {
        self._selectedStep = .init(initialValue: step.rawValue)
        self.step = step
    }
    
    init() {
        let step: PlaygroundStep = .playground
        self._selectedStep = .init(initialValue: step.rawValue)
        self.step = step
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
