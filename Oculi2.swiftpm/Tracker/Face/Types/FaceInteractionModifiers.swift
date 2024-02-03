//
//  FaceInteractionModifiers.swift
//
//
//  Created by Evan Crow on 2/2/24.
//

import Foundation
import SwiftUI

extension View {
    /// Listens for a specific number of blinks on a view.
    /// - Parameters:
    ///   - numberOfBlinks: Number of blinks to listen for, CANNOT be the same as the amount for Quick Actions.
    func onBlink(
        name: String,
        interactionManager: InteractionManager,
        numberOfBlinks: Int = LegacyUXDefaults.defaultBlinksForInteraction,
        action: @escaping () -> Void
    ) -> some View {
        if numberOfBlinks == LegacyUXDefaults.quickActionBlinks {
            fatalError(
                "\(numberOfBlinks) blinks is reserved for Quick Actions. Change the number of blinks or use onQuickAction."
            )
        }

        var listener: InteractionListener?

        return self.modifier(
            ViewBoundsListenerModifier { bounds in
                listener = BlinkListener(
                    id: "blink-listener-\(name)",
                    numberOfBlinks: numberOfBlinks,
                    boundingBox: bounds,
                    action: {
                        SoundEffectHelper.shared.playAudio(for: .onAction)
                        action()
                    }
                )

                interactionManager.updateListener(listener!)
            }
        ).onDisappear {
            if let listener = listener {
                interactionManager.removeListener(listener)
            }
        }
    }

    func onLongBlink(
        name: String,
        interactionManager: InteractionManager,
        duration: Int,
        action: @escaping () -> Void
    ) -> some View {
        var listener: InteractionListener?

        return self.modifier(
            ViewBoundsListenerModifier { bounds in
                listener = LongBlinkListener(
                    id: "long-blink-listener-\(name)", duration: duration,
                    boundingBox: bounds, action: action)

                interactionManager.updateListener(listener!)
            }
        ).onDisappear {
            if let listener = listener {
                interactionManager.removeListener(listener)
            }
        }
    }

    /// - Parameters:
    ///   - priority: Value from 0-1 which ranks how important this Quick Action is compared to others
    ///               (if multiple are present). Default is 0.5.
    func onQuickAction(
        name: String,
        interactionManager: InteractionManager,
        priority: Double = 0.5,
        overrideIsTracking: Bool = false,
        cornerRadius: CGFloat = LegacyUXDefaults.backgroundCornerRadius,
        conditionsMet: @escaping () -> Bool,
        action: @escaping () -> Void
    ) -> some View {
        var listener: InteractionListener?

        var viewWithListeners: some View {
            self
                .onAppear {
                    listener = QuickActionListener(
                        id: "quick-action-listener-\(name)",
                        priority: priority,
                        overrideTracking: overrideIsTracking,
                        conditionsMet: conditionsMet,
                        action: {
                            SoundEffectHelper.shared.playAudio(for: .onAction)
                            action()
                        }
                    )

                    interactionManager.updateListener(listener!)
                }
                .onDisappear {
                    if let listener = listener {
                        interactionManager.removeListener(listener)
                    }
                }
        }

        @ViewBuilder
        var viewWithQuickActionIdentifiers: some View {
            viewWithListeners
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.mint.opacity(priority), lineWidth: conditionsMet() ? 4 : 0)
                )
        }

        return viewWithQuickActionIdentifiers
    }
}
