//
//  DebugPopup.swift
//
//
//  Created by Evan Crow on 1/28/24.
//

import SwiftUI

struct DebugPopup: View {
    @State var expanded = false
    @EnvironmentObject var navigationModel: NavigationModel
    @EnvironmentObject var faceTrackerModel: FaceTrackerModel
    @EnvironmentObject var handTrackerModel: HandTrackerModel

    var body: some View {
        Popup(expanded: $expanded, collapsedIcon: "scope") {
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
                        text: handTrackerModel.state.label,
                        expandedSize: false
                    )

                    if let currentHand = handTrackerModel.currentHand {
                        TextSection(
                            header: "Distances",
                            text: currentHand.tipDistances.map { $0.formatted() }.joined(
                                separator: ", "),
                            expandedSize: false
                        )
                    }
                }

                Button {
                    expanded = false
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
