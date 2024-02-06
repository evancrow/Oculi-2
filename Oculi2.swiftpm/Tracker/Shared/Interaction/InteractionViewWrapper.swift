//
//  InteractionViewWrapper.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/21/22.
//

import SwiftUI

public struct InteractionViewWrapper<Content: View>: View {
    @ObservedObject var model: TrackerModel
    @ObservedObject var interactionManager: InteractionManager
    @ObservedObject var permissionModel = PermissionModel.shared
    @ObservedObject var speechRecognizerModel = SpeechRecognizerModel()

    @StateObject var geometryProxyValue = GeometryProxyValue()
    @State var keyboardVisible = false

    private let content: Content

    @ViewBuilder
    var permissionErrorView: some View {
        if let nextRequiredPermission = permissionModel.nextRequiredPermission {
            switch nextRequiredPermission.1 {
            case .denied, .unknown:
                ErrorView(
                    error:
                        "Please give \(nextRequiredPermission.0.rawValue) permission in settings",
                    buttonText: "Check Again",
                    buttonAction: model.resetAVModel
                )
            case .unable:
                ErrorView(
                    error:
                        "Your device is not able to support requirment: \(nextRequiredPermission.0.rawValue)"
                )
            default:
                EmptyView()
            }
        } else {
            EmptyView()
        }
    }

    public var body: some View {
        GeometryReader { geom in
            ZStack {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        content
                        Spacer()
                    }
                    Spacer()
                }

                if interactionManager.showCursor && model.calibrated {
                    Cursor(offset: interactionManager.cursorOffset)
                        .opacity(interactionManager.switchToDragging ? 0.5 : 1)
                }
            }
            .environmentObject(geometryProxyValue)
            .environmentObject(interactionManager)
            .environmentObject(speechRecognizerModel)
            .environmentObject(model)
            .environmentObject(model.avModel)
            .environmentObject(model.faceTrackerModel)
            .environmentObject(model.handTrackerModel)
            .environmentObject(model.handTrackerModel.calibrationModel)
            .padding(.bottom)
            .useEffect(deps: geom.size) { _ in
                interactionManager.updateViewValues(geom.size)
                geometryProxyValue.geom = geom
            }.useEffect(deps: geom.safeAreaInsets.bottom) { bottomSafeArea in
                keyboardVisible = bottomSafeArea > 100
            }.onChange(of: keyboardVisible) { _ in
                // model.keyboardVisible = keyboardVisible
            }.onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
            }
        }

        /*
        ZStack {
            if permissionModel.nextRequiredPermission == nil {
                if !keyboardVisible && model.isTracking {

                }
            } else if permissionModel.nextRequiredPermission?.1 != .unknown {
                permissionErrorView
            }
        }
         */
    }

    public init(content: () -> Content) {
        let trackerModel = TrackerModel(avModel: AVModel())
        self.model = trackerModel
        self.interactionManager = trackerModel.interactionManager
        self.content = content()
    }
}
