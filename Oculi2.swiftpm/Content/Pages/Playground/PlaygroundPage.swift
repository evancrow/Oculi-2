//
//  PlaygroundPage.swift
//
//
//  Created by Evan Crow on 1/28/24.
//

import SwiftUI

enum PlaygroundOption: String, CaseIterable {
    case calibrate = "Calibrate"
    case tutorial = "Tutorial"

    var title: String {
        self.rawValue
    }
}

enum PlaygroundStep: String, CaseIterable {
    case playground = "Playground"
    case developers = "Developers"
    case impact = "Impact"

    var title: String {
        switch self {
        case .playground:
            return "Experimental Playground"
        case .developers:
            return "How Developers Use Oculi"
        case .impact:
            return "Oculi’s Use Cases & Impact"
        }
    }

    var subtitle: String {
        switch self {
        case .playground:
            "Here you can try interacting with different elements."
        case .developers:
            "Here's how effortlessly developers, including those at Apple, can integrate Oculi into their SwiftUI applications."
        case .impact:
            "I created Oculi with a vision to empower individuals in my community and across the globe facing mobility challenges. The second iteration of Oculi builds upon the success of the initial version, enhancing ease of use, reliability, and accessibility."
        }
    }
}

struct PlaygroundPage: View {
    @EnvironmentObject private var navigationModel: NavigationModel
    @State var step: PlaygroundStep
    @State private var selectedStep: String
    @State private var playgroundOption: String = ""

    var body: some View {
        PageContainer {
            HStack {
                Spacer()
                VStack(spacing: PaddingSizes._52) {
                    VStack(spacing: PaddingSizes._52) {
                        VStack(spacing: PaddingSizes._6) {
                            Text(step.title)
                                .font(FontStyles.Title.font)

                            Text(step.subtitle)
                                .font(FontStyles.Body.font)
                                .multilineTextAlignment(.center)
                        }.frame(maxWidth: UXDefaults.maximumPageWidth)

                        switch step {
                        case .playground:
                            PlaygroundView()
                        case .developers:
                            Spacer()
                            DevelopersView()
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        case .impact:
                            Spacer()
                            ImpactView()
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                    }

                    VStack(spacing: PaddingSizes._12) {
                        HStack(spacing: PaddingSizes._32) {
                            SegmentedPicker(
                                selectedOption: $selectedStep,
                                options: PlaygroundStep.allCases.map(\.rawValue)
                            )

                            SegmentedPicker(
                                selectedOption: $playgroundOption,
                                options: PlaygroundOption.allCases.map(\.rawValue),
                                showSelected: false
                            )
                        }

                        Text("Tap or Swipe Between Pages")
                            .font(FontStyles.Body2.font)
                    }
                }

                Spacer()
            }
        }.onChange(of: selectedStep) { newValue in
            self.step = PlaygroundStep(rawValue: newValue) ?? .playground
        }.onChange(of: playgroundOption) { _ in
            switch PlaygroundOption(rawValue: playgroundOption) {
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
        self._selectedStep = State(initialValue: step.rawValue)
        self.step = step
    }

    init() {
        let step: PlaygroundStep = .playground
        self._selectedStep = State(initialValue: step.rawValue)
        self.step = step
    }
}

#Preview {
    GeometryReader { geom in
        PlaygroundPage(step: .playground)
            .environmentObject(GeometryProxyValue(geom: geom))
            .environmentObject(InteractionManager())
            .environmentObject(SpeechRecognizerModel())
    }
}

#Preview {
    GeometryReader { geom in
        PlaygroundPage(step: .developers)
            .environmentObject(GeometryProxyValue(geom: geom))
            .environmentObject(InteractionManager())
            .environmentObject(SpeechRecognizerModel())
    }
}
