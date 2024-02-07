//
//  HandInteractionModifiers.swift
//
//
//  Created by Evan Crow on 2/2/24.
//

import Combine
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
                        numberOfTaps: numberOfTaps,
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
    @State var listener: DragListener?
    @State var draggingListener: AnyCancellable?
    @State var offset: CGSize = .zero

    let name: String
    var offsetView: Bool = true
    let onDrag: (CGSize) -> Void

    func body(content: Content) -> some View {
        content
            .modifier(
                ViewBoundsListenerModifier { bounds in
                    listener = DragListener(
                        id: "drag-listener-\(name)",
                        boundingBox: bounds.offsetBy(dx: offset.width, dy: offset.height),
                        delta: offset
                    ) { offset in
                        self.offset = offset
                        onDrag(offset)
                    }
                    draggingListener = listener?.$dragging.sink { value in
                        if !value {
                            interactionManager.updateListener(listener!)
                        }
                    }

                    if !listener!.dragging {
                        interactionManager.updateListener(listener!)
                    }
                }
            )
            .onDisappear {
                if let listener = listener {
                    interactionManager.removeListener(listener)
                }
            }
            .offset(offsetView ? offset : .zero)
    }
}

extension View {
    func onDrag(
        name: String,
        onDrag: @escaping (CGSize) -> Void
    ) -> some View {
        return self.modifier(
            DragViewModifier(name: name, onDrag: onDrag)
        )
    }
}

// MARK: - Scroll
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
                DispatchQueue.main.async {
                    self.scrollView = scrollView
                }
            }
            .onScroll(
                name: name,
                direction: direction
            ) { amount in
                guard let scrollView = scrollView else {
                    return
                }

                interactionManager.scrolling = true
                let currentOffset =
                    direction == .vertical ? scrollView.contentOffset.y : scrollView.contentOffset.x
                var newOffset = currentOffset + amount

                DispatchQueue.main.async {
                    newOffset = max(
                        10,
                        min(
                            amount,
                            direction == .vertical
                                ? scrollView.contentSize.height - scrollView.frame.height
                                : scrollView.contentSize.width - scrollView.frame.width
                        )
                    )

                    print(newOffset)

                    scrollView.setContentOffset(
                        CGPoint(
                            x: direction == .horizontal ? newOffset : 0,
                            y: direction == .vertical ? newOffset : 0
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
            DragViewModifier(name: name, offsetView: false) { delta in
                let dragDirection: Axis = delta.height > delta.width ? .vertical : .horizontal
                let amount = dragDirection == .vertical ? delta.height : delta.width
                if dragDirection == direction {
                    onScroll(amount * HandTrackerDefaults.ScrollMultiplier)
                }
            }
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

// MARK: - Zoom
private struct ZoomViewModifier: ViewModifier {
    @EnvironmentObject var interactionManager: InteractionManager
    @State var listener: InteractionListener?
    @State var zooming = true
    @Binding var scale: Double

    let name: String
    let minZoomDepth: Int
    var minScale: Double {
        1 / Double(truncating: pow(2, minZoomDepth) as NSNumber)
    }
    let maxZoomDepth: Int
    var maxScale: Double {
        Double(truncating: pow(2, maxZoomDepth) as NSNumber)
    }

    func body(content: Content) -> some View {
        content
            .onTap(
                name: name,
                numberOfTaps: 2
            ) {
                if zooming {
                    // Check if less than max zoom
                    // -> zoomIn
                    // else
                    // -> zoomOut
                    if scale < maxScale {
                        zoomIn()
                    } else {
                        zoomOut()
                    }
                } else {
                    // Check if more than min zoom
                    // -> zoomOut
                    // else
                    // -> zoomIn
                    if scale > minScale {
                        zoomOut()
                    } else {
                        zoomIn()
                    }
                }
            }
    }

    func zoomIn() {
        zooming = true
        scale = scale * 2
    }

    func zoomOut() {
        zooming = false
        scale = scale / 2
    }
}

extension View {
    /// Zooms in and out when a double tap occurs.
    /// - Parameters:
    ///   - minZoomDepth: Number of time a user can zoom out from the starting state. For example, if I could zoom out twice, `minZoomDepth` would be 2.
    ///   - maxZoomDepth: Number of time a user can zoom in from the starting state. For example, if I could zoom in twice, `maxZoomDepth` would be 2.
    ///   - scale: The scale object should appear at. Recommended to start at 1.
    func onZoom(
        name: String,
        minZoomDepth: Int,
        maxZoomDepth: Int,
        scale: Binding<Double>
    ) -> some View {
        return self.modifier(
            ZoomViewModifier(
                scale: scale,
                name: name,
                minZoomDepth: minZoomDepth,
                maxZoomDepth: maxZoomDepth
            )
        )
    }
}
