//
//  FaceTrackerModel.swift
//
//
//  Created by Evan Crow on 1/15/24.
//

import Foundation
import SwiftUI
import Vision

public class FaceTrackerModel: ObservableObject {
    private var interactionManager: InteractionManager!

    @Published public private(set) var quality: VisionQualityState = .NotDetected

    /// Geometry from when tracking first began, used as a baseline.
    private var originGeometry: FaceGeometry? = nil
    private var currentGeometry: FaceGeometry? = nil

    // MARK: - Head Movement
    private func updateOffset(with geometry: FaceGeometry) {
        guard let originGeometry = originGeometry else {
            originGeometry = geometry
            return
        }

        let yaw = geometry.yaw
        let originYaw = originGeometry.yaw
        let xOffset: CGFloat = {
            if yaw > originYaw {
                return yaw - originYaw
            } else {
                return -(originYaw - yaw)
            }
        }()

        let pitch = geometry.pitch
        let originPitch = originGeometry.pitch
        let yOffset: CGFloat = {
            if pitch > originPitch {
                return pitch - originPitch
            } else {
                return -(originPitch - pitch)
            }
        }()

        let newXOffset = (xOffset * UXDefaults.cursorMovementMultiplier.width)
        let newYOffset = (yOffset * UXDefaults.cursorMovementMultiplier.height)

        interactionManager.moveCursorOffset(by: CGPoint(x: newXOffset, y: newYOffset))
    }
    
    @discardableResult
    public func captureOriginGeometry() -> Bool {
        guard let currentGeometry = currentGeometry else {
            return false
        }
        
        self.originGeometry = currentGeometry
        print("SET FACE ORIGIN GEOM")
        return true
    }
    
    // MARK: - init
    init(interactionManager: InteractionManager) {
        self.interactionManager = interactionManager
    }
}

// MARK: - FaceTrackerDelegate
extension FaceTrackerModel: FaceTrackerDelegate {
    func faceGeometryDidChange(_ geometry: FaceGeometry) {
        guard quality != .NotDetected else {
            return
        }

        currentGeometry = geometry
        updateOffset(with: geometry)
    }

    func faceCaptureQualityDidChange(_ quality: VisionQualityState) {
        DispatchQueue.main.async { [self] in
            self.quality = quality
            
            if quality == .NotDetected {
                currentGeometry = nil
            }
        }
    }
}
