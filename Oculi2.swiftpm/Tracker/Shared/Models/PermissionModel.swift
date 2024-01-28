//
//  PermissionModel.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/6/22.
//

import AVKit
import Combine
import Speech

enum PermissionState {
    case unknown
    case authorized
    case denied
    case unable
}

enum Permission: String, CaseIterable {
    case camera = "camera"
    case microphone = "microphone"
    case speechRecognition = "speech recognition"
}

class PermissionModel: ObservableObject {
    static let shared = PermissionModel()
    private let requiredPermissions: [Permission] = [.camera, .microphone, .speechRecognition]

    var nextRequiredPermission: (Permission, PermissionState)? {
        for permission in requiredPermissions {
            let permissionState = getPermissionState(permission: permission)
            if permissionState != .authorized {
                return (permission, permissionState)
            }
        }

        return nil
    }

    /// Gets the permission state from the system.
    public func getPermissionState(permission: Permission) -> PermissionState {
        switch permission {
        case .camera:
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                return .authorized
            case .notDetermined:
                return .unknown
            case .denied:
                return .denied
            case .restricted:
                return .unable
            @unknown default:
                return .unable
            }
        case .microphone:
            switch AVAudioSession.sharedInstance().recordPermission {
            case .granted:
                return .authorized
            case .undetermined:
                return .unknown
            case .denied:
                return .denied
            @unknown default:
                return .unable
            }
        case .speechRecognition:
            switch SFSpeechRecognizer.authorizationStatus() {
            case .authorized:
                return .authorized
            case .denied:
                return .denied
            case .restricted:
                return .unable
            case .notDetermined:
                return .unknown
            @unknown default:
                return .unable
            }
        }
    }

    /// Checks if the user has given permsission to use the input, and requests it if needed.
    public func requestPermissionIfNeeded(
        permission: Permission, completion: @escaping (PermissionState) -> Void
    ) {
        let permissionState = getPermissionState(permission: permission)
        switch permissionState {
        case .unknown:
            switch permission {
            case .camera:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    completion(granted ? .authorized : .denied)
                }
            case .microphone:
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    completion(granted ? .authorized : .denied)
                }
            case .speechRecognition:
                SFSpeechRecognizer.requestAuthorization { (authStatus) in
                    switch authStatus {
                    case .authorized:
                        completion(.authorized)
                    case .denied:
                        completion(.denied)
                    case .restricted, .notDetermined:
                        completion(.unable)
                    @unknown default:
                        completion(.unable)
                    }
                }
            }
        default:
            completion(permissionState)
        }
    }

    public func requestAllRequiredPermissions(completion: @escaping (Bool) -> Void) {
        var allAllowed = true
        for (index, permission) in requiredPermissions.enumerated() {
            requestPermissionIfNeeded(permission: permission) { value in
                if value != .authorized {
                    allAllowed = false
                }

                if index == self.requiredPermissions.count - 1 {
                    completion(allAllowed)
                }
            }
        }
    }
}
