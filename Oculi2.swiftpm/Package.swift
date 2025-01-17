// swift-tools-version: 5.6

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import AppleProductTypes
import PackageDescription

let package = Package(
    name: "Oculi2",
    platforms: [
        .iOS("16")
    ],
    products: [
        .iOSApplication(
            name: "Oculi 2",
            targets: ["AppModule"],
            bundleIdentifier: "com.evan.crow.Oculi.V2",
            teamIdentifier: "2BTUXF52SG",
            displayVersion: "2.0",
            bundleVersion: "1",
            appIcon: .asset("AppIcon"),
            accentColor: .asset("AccentColor"),
            supportedDeviceFamilies: [
                .pad,
                .phone,
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad])),
            ],
            capabilities: [
                .microphone(purposeString: "Oculi uses your Microphone for dictation features."),
                .speechRecognition(
                    purposeString: "Oculi uses Speech Recognition for dictation features."),
                .camera(
                    purposeString:
                        "Oculi uses your front facing camera to detect and track your face."),
            ],
            appCategory: .utilities
        )
    ],
    dependencies: [
        .package(url: "git@github.com:siteline/swiftui-introspect.git", "1.1.2"..<"2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            dependencies: [
                .product(name: "SwiftUIIntrospect", package: "swiftui-introspect")
            ],
            path: ".",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
