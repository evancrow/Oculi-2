//
//  HandCalibrationView.swift
//
//
//  Created by Evan Crow on 1/27/24.
//

import SwiftUI

struct HandCalibrationView: View {
    @ObservedObject var model: HandPoseCalibrationModel
    
    var subtitle: String {
        switch model.calibrationState {
        case .Calibrated:
            return "Calibrated! Oculi is now set up and ready for use."
        case .CalibratingPose, .CalibratingChangePose:
            return "Please follow the instructions below to correctly set up Oculi. Keep your device still in a will lit area."
        case .NotCalibrated:
            return "Oculi quickly needs to calibrate to your hand patterns before you can continue. Click Get Started below to start."
        }
    }
    
    var calibrationTask: String? {
        if case .CalibratingChangePose(let pose) = model.calibrationState {
            switch pose {
            case .flat:
                return "Make a flat hand facing the camera"
            case .pinch:
                return "Pinch your fingers"
            case .point:
                return "Point at the camera"
            case .twoFinger:
                return "Point two fingers at the camera"
            default:
                return nil
            }
        }
        
        return nil
    }
    
    var body: some View {
        SectionPage(italicTitle: "", titleEnd: "Calibration") {
            Text(subtitle)
            
            if case .NotCalibrated = model.calibrationState {
                Button {
                    model.startCalibration()
                } label: {
                    Text("Get Started")
                }.buttonStyle(FilledButtonStyle())
            }
            
            if let calibrationTask {
                Text(calibrationTask)
            }
        }
    }
}

#Preview {
    HandCalibrationView(
        model: HandPoseCalibrationModel()
    )
}
