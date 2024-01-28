//
//  DebugPopup.swift
//
//
//  Created by Evan Crow on 1/28/24.
//

import SwiftUI

struct DebugPopup: View {
    @EnvironmentObject var navigationModel: NavigationModel
    @EnvironmentObject var handTrackerModel: HandTrackerModel

    var body: some View {
        Popup(expanded: false, collapsedIcon: "scope") {
            VStack(spacing: PaddingSizes._32) {
                Text("Debug Tools")
                    .font(FontStyles.Title2.font)

                VStack(spacing: PaddingSizes._12) {
                    TextSection(
                        header: "Quality",
                        text: handTrackerModel.quality.rawValue,
                        expandedSize: false
                    )

                    TextSection(
                        header: "Pose",
                        text: handTrackerModel.currentHandPose.rawValue,
                        expandedSize: false
                    )

                    if let currentHand = handTrackerModel.currentHand {
                        TextSection(
                            header: "Distances",
                            text: currentHand.tipDistances.reduce("") { partialResult, value in
                                partialResult + value.formatted()
                            },
                            expandedSize: false
                        )
                    }
                }

                Button {
                    navigationModel.stack(page: .Calibrate)
                } label: {
                    Text("Re-Calibrate")
                }.buttonStyle(UnderlinedButtonStyle())
            }
        }
    }
}

#Preview {
    DebugPopup()
        .environmentObject(HandTrackerModel(interactionManager: InteractionManager()))
}
