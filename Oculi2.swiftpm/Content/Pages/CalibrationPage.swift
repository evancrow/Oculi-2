//
//  CalibrationPage.swift
//
//
//  Created by Evan Crow on 1/28/24.
//

import SwiftUI

enum CalibrationStep {
    case permission
    case calibrationIntro
    case calibration(handPose: HandPose)
    case done
}

struct CalibrationPage: View {
    @EnvironmentObject var navigationModel: NavigationModel
    @EnvironmentObject var handPoseCalibrationModel: HandPoseCalibrationModel
    @State private var needsToOpenSettings = false
    @State private var step: CalibrationStep {
        didSet {
            if case .calibration(let handPose) = step {
                handPoseCalibrationModel.startCalibration(for: handPose)
            }
        }
    }

    var allPermissionsAccepted: Bool {
        PermissionModel.shared.nextRequiredPermission == nil
    }

    var title: String {
        switch step {
        case .permission:
            "Set Up"
        case .calibrationIntro:
            "Calibration"
        case .calibration(let handPose):
            handPose.title
        case .done:
            "All Done"
        }
    }

    var subtitle: String {
        switch step {
        case .permission:
            "For Oculi to work, it needs access to the following:"
        case .calibrationIntro:
            "Everyone is different! Calibration makes sure your hand movements are properly recognized."
        case .calibration(let handPose):
            handPose.setUpInstruction
        case .done:
            "Oculi is now ready to use."
        }
    }

    @ViewBuilder
    var content: some View {
        switch step {
        case .permission:
            VStack(spacing: PaddingSizes._52) {
                TextSection(header: "Camera", text: "To see your hand movements")
                TextSection(header: "Microphone", text: "For text dictation")
                TextSection(header: "Speech Recognition", text: "For text dictation")

                VStack(spacing: PaddingSizes._12) {
                    Button {
                        if needsToOpenSettings {
                            UIApplication.shared.open(
                                URL(string: UIApplication.openSettingsURLString)!,
                                options: [:],
                                completionHandler: nil
                            )
                        } else {
                            PermissionModel.shared.requestAllRequiredPermissions { allAllowed in
                                if allAllowed {
                                    step = .calibrationIntro
                                } else {
                                    withAnimation(.interactiveSpring) {
                                        needsToOpenSettings = true
                                    }
                                }
                            }
                        }
                    } label: {
                        Text(needsToOpenSettings ? "Enable in Settings" : "Allow")
                    }.buttonStyle(DefaultButtonStyle())

                    if needsToOpenSettings {
                        Text("To continue, please enable these in the Settings app.")
                            .font(FontStyles.Body2.font)

                        Button {
                            PermissionModel.shared.requestAllRequiredPermissions { allAllowed in
                                if allAllowed {
                                    step = .calibrationIntro
                                }
                            }
                        } label: {
                            Text("Recheck Permissions")
                        }.buttonStyle(UnderlinedButtonStyle())
                    }
                }
            }
        case .calibrationIntro:
            VStack(spacing: PaddingSizes._52) {
                TextSection(
                    header: "Tip 1", text: "Use only your dominant hand")
                TextSection(
                    header: "Tip 2",
                    text: "Place your device 1-2 feet away, in a well lit area"
                )
                TextSection(header: "Tip 3", text: "Make clear, and concise hand poses")
                TextSection(header: "Now", text: "When ready, click start to began calibration")

                Button {
                    step = .calibration(handPose: .flat)
                } label: {
                    Text("Start")
                }.buttonStyle(DefaultButtonStyle())
            }.multilineTextAlignment(.center)
        case .calibration(let handPose):
            VStack(spacing: PaddingSizes._52) {
                Text("Hold for \(handPoseCalibrationModel.timeRemaining)")
                    .font(FontStyles.Title2.font)

                Button {
                    handPoseCalibrationModel.skipCalibration()
                    step = .done
                } label: {
                    Text("Skip")
                }.buttonStyle(UnderlinedButtonStyle())
            }.onChange(of: handPoseCalibrationModel.timeRemaining) { newValue in
                if newValue <= 0 {
                    if let nextPose = handPose.nextPose {
                        step = .calibration(handPose: nextPose)
                    } else {
                        handPoseCalibrationModel.finishCalibration()
                        step = .done
                    }
                }
            }
        case .done:
            Button {
                navigationModel.moveToNextPage(popFirst: true)
            } label: {
                Text("Continue")
            }.buttonStyle(DefaultButtonStyle())
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
                }

                content
            }
        }
    }

    // MARK: - init
    fileprivate init(
        step: CalibrationStep,
        needsToOpenSettings: Bool = false
    ) {
        self._step = State(initialValue: step)
        self._needsToOpenSettings = State(initialValue: needsToOpenSettings)
    }

    init() {
        self._step = State(
            initialValue: PermissionModel.shared.nextRequiredPermission == nil
                ? .calibrationIntro : .permission
        )
    }
}

#Preview {
    CalibrationPage(
        step: .permission
    ).environmentObject(
        NavigationModel()
    )
}

#Preview {
    CalibrationPage(
        step: .calibrationIntro
    ).environmentObject(
        NavigationModel()
    )
}

#Preview {
    CalibrationPage(
        step: .calibration(handPose: .flat)
    ).environmentObject(
        NavigationModel()
    )
}

#Preview {
    CalibrationPage(
        step: .done
    ).environmentObject(
        NavigationModel()
    )
}
