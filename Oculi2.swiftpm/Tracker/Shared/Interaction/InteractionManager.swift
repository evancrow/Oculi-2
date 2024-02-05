//
//  InteractionManager.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/5/22.
//

import CoreGraphics
import SwiftUI

public class InteractionManager: ObservableObject {
    // MARK: - Cursor
    private var viewWidth: CGFloat = 0
    private var viewHeight: CGFloat = 0
    private var showCursorTimer: Timer?
   
    var interactionEnabled = false
    @Published var showCursor = false
    @Published private(set) var cursorOffset: CGPoint = .zero {
        didSet {
            if !interactionEnabled {
                showCursor = false
                return
            }
            
            onCursorOffsetChanged()
            showCursor = true
            showCursorTimer?.invalidate()
            showCursorTimer = Timer.scheduledTimer(
                withTimeInterval: UXDefaults.cursorShowTime,
                repeats: false
            ) { [weak self] _ in
                self?.showCursor = false
            }
        }
    }

    private func checkIfOffsetIsInBounds(_ newOffset: CGPoint) -> Bool {
        let padding: CGFloat = PaddingSizes._52

        // Positions relative to the global frame
        let origin = getOrigin()
        let expectedX = origin.x + cursorOffset.x + newOffset.x
        let expectedY = origin.y + cursorOffset.y + newOffset.y

        let withinX = expectedX < (viewWidth - padding) && expectedX > padding
        let withinY = expectedY < (viewHeight - padding) && expectedY > padding

        return withinX && withinY
    }

    public func getCursorBoundingBox() -> CGRect {
        let origin = getOrigin()
        let currentX = origin.x + cursorOffset.x
        let currentY = origin.y + cursorOffset.y
        let offsetForMin = UXDefaults.cursorHeight / 2

        let boundingBox = CGRect(
            x: currentX - offsetForMin,
            y: currentY - offsetForMin,
            width: UXDefaults.cursorHeight,
            height: UXDefaults.cursorHeight
        )

        return boundingBox
    }

    public func setCursorOffset(to point: CGPoint) {
        guard interactionEnabled else {
            return
        }
        
        if checkIfOffsetIsInBounds(point) {
            cursorOffset = point
        }
    }

    public func moveCursorOffset(by value: CGPoint) {
        guard interactionEnabled else {
            return
        }
        
        if checkIfOffsetIsInBounds(value) {
            withAnimation(.linear) {
                cursorOffset.x += value.x
                cursorOffset.y += value.y
            }
        }
    }

    public func resetCursorOffset() {
        if viewWidth > 0 && viewHeight > 0 {
            cursorOffset = getOrigin()
        } else {
            cursorOffset = .zero
        }
    }

    private func getOrigin() -> CGPoint {
        return CGPoint(x: viewWidth / 2, y: viewHeight / 2)
    }

    // MARK: - Listeners
    private var interactionListeners = [InteractionListener]()

    public func addListener(_ listener: InteractionListener) {
        interactionListeners.append(listener)
    }

    public func removeListener(_ listener: InteractionListener) {
        interactionListeners.removeAll { $0 == listener }
    }

    public func updateListener(_ listener: InteractionListener) {
        removeListener(listener)
        addListener(listener)
    }

    fileprivate func runListenersWithMatchingBoundingBox(
        boundingBox: CGRect,
        possibleListeners: [InteractionListener]
    ) {
        guard interactionEnabled else {
            return
        }
        
        for listener in possibleListeners {
            // Calculate all corners of the boundingBox
            let origin = boundingBox.origin
            let size = boundingBox.size
            let topRight = CGPoint(x: origin.x + size.width, y: origin.y)
            let bottomLeft = CGPoint(x: origin.x, y: origin.y + size.height)
            let bottomRight = CGPoint(x: origin.x + size.width, y: origin.y + size.height)

            // Check if listener.boundingBox contains any of these points
            if listener.boundingBox.contains(origin) ||
               listener.boundingBox.contains(topRight) ||
               listener.boundingBox.contains(bottomLeft) ||
               listener.boundingBox.contains(bottomRight) 
            {
                // listener.boundingBox contains at least one corner of boundingBox.
                listener.action()
            }
        }
    }

    // MARK: - Config
    public func updateViewValues(_ size: CGSize) {
        self.viewWidth = size.width
        self.viewHeight = size.height
    }
}

// MARK: - Face
extension InteractionManager {
    private var blinkListeners: [BlinkListener] {
        interactionListeners.compactMap { $0 as? BlinkListener }
    }
    private var longBlinkListeners: [LongBlinkListener] {
        interactionListeners.compactMap { $0 as? LongBlinkListener }
    }
    private var quickActionListeners: [QuickActionListener] {
        interactionListeners.compactMap { $0 as? QuickActionListener }
    }

    // MARK: - Blink Methods
    public func onBlink(numberOfBlinks: Int, isTracking: Bool) {
        if numberOfBlinks == LegacyUXDefaults.quickActionBlinks {
            handleQuickActions(isTracking: isTracking)
            return
        }

        // Only allow Quick Actions if tracking is false, else just return.
        guard isTracking else {
            return
        }

        // Filter listeners to those that match the number of blinks.
        let possibleListeners = blinkListeners.filter { $0.numberOfBlinks == numberOfBlinks }
        runListenersWithMatchingBoundingBox(
            boundingBox: getCursorBoundingBox(),
            possibleListeners: possibleListeners
        )
    }

    public func onLongBlink(duration: Int) {
        // Filter listeners to those that match the number of blinks.
        let possibleListeners = longBlinkListeners.filter { $0.duration == duration }
        runListenersWithMatchingBoundingBox(
            boundingBox: getCursorBoundingBox(),
            possibleListeners: possibleListeners
        )
    }

    // MARK: - Quick Actions
    private func handleQuickActions(isTracking: Bool) {
        // Sort by priority, greatest to least.
        let listeners = quickActionListeners.sorted { $0.priority > $1.priority }

        for listener in listeners {
            // Run the first listener's (with passing conditions) action.
            if listener.conditionsMet(), isTracking || listener.overrideIsTracking {
                listener.action()
                break
            }
        }
    }
}

// MARK: - Hand
extension InteractionManager {
    private var tapListeners: [TapListener] {
        interactionListeners.compactMap { $0 as? TapListener }
    }
    private var longTapListeners: [LongTapListener] {
        interactionListeners.compactMap { $0 as? LongTapListener }
    }
    private var dragListeners: [DragListener] {
        interactionListeners.compactMap { $0 as? DragListener }
    }
    private var scrollListeners: [ScrollListener] {
        interactionListeners.compactMap { $0 as? ScrollListener }
    }
    private var zoomListeners: [ZoomListener] {
        interactionListeners.compactMap { $0 as? ZoomListener }
    }

    // MARK: - Tap
    public func onTap(numberOfTaps: Int) {
        // Filter listeners to those that match the number of taps.
        let possibleListeners = tapListeners.filter { $0.numberOfTaps == numberOfTaps }
        runListenersWithMatchingBoundingBox(
            boundingBox: getCursorBoundingBox(),
            possibleListeners: possibleListeners
        )

        print(">>> TAP <<<")
        print("Number of Taps:", numberOfTaps)
        print("Bounding Box:", getCursorBoundingBox())
    }

    public func onLongTap(duration: Int) {
        let possibleListeners = longTapListeners.filter { $0.duration == duration }
        runListenersWithMatchingBoundingBox(
            boundingBox: getCursorBoundingBox(),
            possibleListeners: possibleListeners
        )

        print(">>> LONG TAP <<<")
        print("Duration:", duration)
        print("Bounding Box:", getCursorBoundingBox())
    }

    public func onDrag(delta: CGSize) {
        let possibleListeners = dragListeners
        possibleListeners.forEach {
            $0.delta = delta
        }
        runListenersWithMatchingBoundingBox(
            boundingBox: getCursorBoundingBox(),
            possibleListeners: possibleListeners
        )

        print(">>> Drag <<<")
        print("Delta:", delta)
        print("Bounding Box:", getCursorBoundingBox())
    }

    // MARK: - Scroll
    public func onScroll(direction: Axis, distance: CGFloat) {
        let possibleListeners = scrollListeners.filter { $0.direction == direction }
        possibleListeners.forEach {
            $0.distance = distance
        }
        runListenersWithMatchingBoundingBox(
            boundingBox: getCursorBoundingBox(),
            possibleListeners: possibleListeners
        )

        print(">>> SCROLL <<<")
        print("Direction:", direction)
        print("Distance:", distance)
        print("Bounding Box:", getCursorBoundingBox())
    }

    // MARK: - Zoom
    public func onZoom(scale: Double) {
        let possibleListeners = zoomListeners
        possibleListeners.forEach {
            $0.scale = scale
        }
        runListenersWithMatchingBoundingBox(
            boundingBox: getCursorBoundingBox(),
            possibleListeners: possibleListeners
        )

        print(">>> ZOOM <<<")
        print("Scale:", scale)
        print("Bounding Box:", getCursorBoundingBox())
    }
}

// MARK: - Shared
extension InteractionManager {
    private var hoverListeners: [HoverListener] {
        interactionListeners.compactMap { $0 as? HoverListener }
    }

    fileprivate func onCursorOffsetChanged() {
        let boundingBox = getCursorBoundingBox()
        
        // Updates each listner if the cursor is hovering over it's view.
        for listener in hoverListeners {
            withAnimation {
                listener.isHovering = listener.boundingBox.contains(boundingBox.origin)
            }
        }
    }
}
