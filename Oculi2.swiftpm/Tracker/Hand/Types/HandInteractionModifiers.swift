//
//  HandInteractionModifiers.swift
//
//
//  Created by Evan Crow on 2/2/24.
//

import Foundation
import SwiftUI
import SwiftUIIntrospect

// MARK: - Tap
private struct TapViewModifier: ViewModifier {
    @EnvironmentObject var interactionManager: InteractionManager
    @State var listener: InteractionListener?

    let name: String
    let numberOfTaps: Int
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .modifier(
                ViewBoundsListenerModifier { bounds in
                    listener = TapListener(
                        id: "tap-listener-\(name)",
                        boundingBox: bounds,
                        action: action
                    )

                    interactionManager.updateListener(listener!)
                }
            ).onDisappear {
                if let listener = listener {
                    interactionManager.removeListener(listener)
                }
            }
    }
}

extension View {
    func onTap(
        name: String,
        numberOfTaps: Int = 1,
        action: @escaping () -> Void
    ) -> some View {
        return self.modifier(
            TapViewModifier(
                name: name,
                numberOfTaps: numberOfTaps,
                action: action
            )
        )
    }
}

// MARK: - LongTap
private struct LongTapViewModifier: ViewModifier {
    @EnvironmentObject var interactionManager: InteractionManager
    @State var listener: InteractionListener?

    let name: String
    let duration: Int
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .modifier(
                ViewBoundsListenerModifier { bounds in
                    listener = LongTapListener(
                        id: "long-tap-listener-\(name)",
                        duration: duration,
                        boundingBox: bounds,
                        action: action
                    )

                    interactionManager.updateListener(listener!)
                }
            ).onDisappear {
                if let listener = listener {
                    interactionManager.removeListener(listener)
                }
            }
    }
}

extension View {
    func onLongTap(
        name: String,
        duration: Int = HandTrackerDefaults.LongPinchDuration,
        action: @escaping () -> Void
    ) -> some View {
        return self.modifier(
            LongTapViewModifier(
                name: name,
                duration: duration,
                action: action
            )
        )
    }
}

// MARK: - Drag
private struct DragViewModifier: ViewModifier {
    @EnvironmentObject var interactionManager: InteractionManager
    @State var listener: InteractionListener?

    let name: String
    let onDrag: (CGSize) -> Void

    func body(content: Content) -> some View {
        content
            .modifier(
                ViewBoundsListenerModifier { bounds in
                    listener = DragListener(
                        id: "drag-listener-\(name)",
                        boundingBox: bounds,
                        onDrag: onDrag
                    )

                    interactionManager.updateListener(listener!)
                }
            ).onDisappear {
                if let listener = listener {
                    interactionManager.removeListener(listener)
                }
            }
    }
}

extension View {
    func onDrag(
        name: String,
        onDrag: @escaping (CGSize) -> Void
    ) -> some View {
        return self.modifier(
            DragViewModifier(
                name: name,
                onDrag: onDrag
            )
        )
    }
}

// MARK: - Scroll
private struct ScrollViewModifier: ViewModifier {
    @EnvironmentObject var interactionManager: InteractionManager
    @State var listener: InteractionListener?

    let name: String
    let direction: Axis
    let onScroll: (CGFloat) -> Void

    func body(content: Content) -> some View {
        content
            .modifier(
                ViewBoundsListenerModifier { bounds in
                    listener = ScrollListener(
                        id: "scroll-listener-\(name)",
                        direction: direction,
                        boundingBox: bounds,
                        onScroll: onScroll
                    )

                    interactionManager.updateListener(listener!)
                }
            ).onDisappear {
                if let listener = listener {
                    interactionManager.removeListener(listener)
                }
            }
    }
}

private struct AutoScrollViewModifier: ViewModifier {
    @EnvironmentObject var interactionManager: InteractionManager
    @State var listener: InteractionListener?
    @State var scrollView: UIScrollView?

    let name: String
    let direction: Axis

    func body(content: Content) -> some View {
        content
            .introspect(
                .scrollView,
                on: .iOS(.v16, .v17)
            ) { scrollView in
                self.scrollView = scrollView
            }
            .onScroll(
                name: name,
                direction: direction
            ) { amount in
                DispatchQueue.main.async {
                    self.scrollView?.setContentOffset(
                        CGPoint(
                            x: direction == .horizontal ? amount : 0,
                            y: direction == .vertical ? amount : 0
                        ),
                        animated: false
                    )
                }
            }
    }
}

extension View {
    /// Adds a listener for when a scroll gesture is detected.
    func onScroll(
        name: String,
        direction: Axis,
        onScroll: @escaping (CGFloat) -> Void
    ) -> some View {
        return self.modifier(
            ScrollViewModifier(
                name: name,
                direction: direction,
                onScroll: onScroll
            )
        )
    }

    /// Adds a listener for when a scroll gesture is detected and automatically moves an underlying ScrollView.
    func followScroll(
        name: String,
        direction: Axis
    ) -> some View {
        return self.modifier(
            AutoScrollViewModifier(name: name, direction: direction)
        )
    }
}
