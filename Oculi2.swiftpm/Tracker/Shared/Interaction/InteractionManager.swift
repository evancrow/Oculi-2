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

    var interactionEnabled = false

    // MARK: - Scrolling
    var scrolling = false {
        didSet {
            if scrolling {
                scrollingTimer?.invalidate()
                scrollingTimer = Timer.scheduledTimer(
                    withTimeInterval: 1,
                    repeats: false
                ) { [weak self] _ in
                    self?.scrolling = false
                }
            }
        }
    }
    private var scrollingTimer: Timer?

    // MARK: - Dragging
    @Published var switchToDragging = false {
        didSet {
            if !switchToDragging {
                activeDragListener?.dragging = false
                activeDragListener?.action()
                activeDragListener = nil
            }
        }
    }
    var activeDragListener: DragListener?

    // MARK: - Cursor
    @Published var showCursor = false
    private var showCursorTimer: Timer?
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
        var origin = getOrigin()
        origin.add(point: cursorOffset)
        let offsetForMin = UXDefaults.cursorHeight / 2

        let boundingBox = CGRect(
            x: origin.x - offsetForMin,
            y: origin.y - offsetForMin,
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
                if switchToDragging || scrolling {
                    onDrag(delta: CGSize(width: value.x, height: value.y))
                }

                if !scrolling {
                    cursorOffset.add(point: value)
                }
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
            if listener.boundingBox.contains(origin)
                || listener.boundingBox.contains(topRight)
                || listener.boundingBox.contains(bottomLeft)
                || listener.boundingBox.contains(bottomRight)
            {
                // listener.boundingBox contains at least one corner of boundingBox.
                listener.action()

                if let listener = listener as? DragListener {
                    self.activeDragListener = listener
                }
            }
        }
    }

    // MARK: - Config
    public func updateViewValues(_ size: CGSize) {
        self.viewWidth = size.width
        self.viewHeight = size.height
    }
}

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
        guard !switchToDragging else {
            return
        }

        // Filter listeners to those that match the number of taps.
        let possibleListeners = tapListeners.filter { $0.numberOfTaps == numberOfTaps }
        runListenersWithMatchingBoundingBox(
            boundingBox: getCursorBoundingBox(),
            possibleListeners: possibleListeners
        )
    }

    public func onLongTap(duration: Int) {
        guard !switchToDragging else {
            return
        }

        let possibleListeners = longTapListeners.filter { $0.duration == duration }
        runListenersWithMatchingBoundingBox(
            boundingBox: getCursorBoundingBox(),
            possibleListeners: possibleListeners
        )
    }

    public func onDrag(delta: CGSize) {
        func updateActiveDragOffset() {
            guard let activeDragListener = activeDragListener else {
                return
            }

            activeDragListener.dragging = true
            activeDragListener.delta.width += delta.width
            activeDragListener.delta.height += delta.height
            activeDragListener.action()
        }

        guard switchToDragging else {
            return
        }

        print(dragListeners)
        
        if activeDragListener == nil {
            runListenersWithMatchingBoundingBox(
                boundingBox: getCursorBoundingBox(),
                possibleListeners: dragListeners
            )
        }

        updateActiveDragOffset()
    }

    // MARK: - Zoom
    public func onZoom(scale: Double) {
        guard !switchToDragging else {
            return
        }

        let possibleListeners = zoomListeners
        possibleListeners.forEach {
            $0.scale = scale
        }
        runListenersWithMatchingBoundingBox(
            boundingBox: getCursorBoundingBox(),
            possibleListeners: possibleListeners
        )
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
