//
//  InteractionModifiers.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/5/22.
//

import SwiftUI

struct ViewBoundsListenerModifier: ViewModifier {
    let onViewBoundsChanged: (CGRect) -> Void

    @State private var bounds: Anchor<CGRect>?
    @EnvironmentObject private var geometryProxyValue: GeometryProxyValue

    func body(content: Content) -> some View {
        content
            .anchorPreference(
                key: BoundsPreferenceKey.self,
                value: .bounds
            ) { $0 }
            .onPreferenceChange(BoundsPreferenceKey.self) { bounds in
                bounds.map {
                    self.bounds = $0
                }
            }.useEffect(deps: geometryProxyValue.geomUpdated) { geom in
                updateBounds()
            }.useEffect(deps: bounds) { _ in
                updateBounds()
            }
    }

    func updateBounds() {
        guard let geom = geometryProxyValue.geom,
            let bounds = bounds
        else {
            return
        }

        onViewBoundsChanged(geom[bounds])
    }
}

extension View {
    func onViewBoundsChange(
        onChange: @escaping (CGRect) -> Void
    ) -> some View {
        self.modifier(
            ViewBoundsListenerModifier(
                onViewBoundsChanged: onChange)
        )
    }
}

// MARK: - Shared
private struct HoverViewModifier: ViewModifier {
    @EnvironmentObject var interactionManager: InteractionManager
    @State var listener: InteractionListener?

    let name: String
    let onHoverStateChanged: (Bool) -> Void

    func body(content: Content) -> some View {
        content
            .onViewBoundsChange { bounds in
                listener = HoverListener(
                    id: "hover-listener-\(name)",
                    boundingBox: bounds,
                    onHoverChanged: { isHovering in
                        onHoverStateChanged(isHovering)
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
}

extension View {
    /// Adds a listener for when the eye cursor is over the view.
    func onHover(
        name: String,
        onHoverStateChanged: @escaping (Bool) -> Void
    ) -> some View {
        return self.modifier(
            HoverViewModifier(name: name, onHoverStateChanged: onHoverStateChanged)
        )
    }
}
