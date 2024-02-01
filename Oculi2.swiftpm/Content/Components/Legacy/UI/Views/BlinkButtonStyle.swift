//
//  BlinkButtonStyle.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/5/22.
//

import SwiftUI

struct BlinkButtonStyleConfig {
    let textColor: Color
    let backgroundColor: Color
    let cornerRadius: CGFloat
    /// When `true`, will show the `EyeIcon` telling the user how to interact with the button.
    let showInteractionDetails: Bool

    static let basic = BlinkButtonStyleConfig(
        textColor: .blue,
        backgroundColor: .blue.opacity(LegacyUXDefaults.backgroundOpacity),
        cornerRadius: LegacyUXDefaults.backgroundCornerRadius,
        showInteractionDetails: true)

    /// A red alternative version to `basic`
    static let basicRedAlt = BlinkButtonStyleConfig(
        textColor: .red,
        backgroundColor: .red.opacity(LegacyUXDefaults.backgroundOpacity),
        cornerRadius: LegacyUXDefaults.backgroundCornerRadius.binade,
        showInteractionDetails: true)
}

struct BlinkButtonStyle: ViewModifier {
    var config: BlinkButtonStyleConfig = .basic
    var hovering = false
    var isEnabled = true

    var opacityMultiplier: CGFloat {
        isEnabled
            ? (hovering ? LegacyUXDefaults.hoverOpacityMultiplier : 1)
            : LegacyUXDefaults.disabledOpacityMultiplier
    }

    func body(content: Content) -> some View {
        content
            .fixedSize()
            .padding()
            .foregroundColor(config.textColor)
            .background(
                config.backgroundColor.opacity(opacityMultiplier).cornerRadius(config.cornerRadius)
            )
    }
}

struct ButtonConfigStyle: EnvironmentKey {
    static let defaultValue: BlinkButtonStyleConfig = .basic
}

extension EnvironmentValues {
    var buttonConfigStyle: BlinkButtonStyleConfig {
        get { self[ButtonConfigStyle.self] }
        set { self[ButtonConfigStyle.self] = newValue }
    }
}
