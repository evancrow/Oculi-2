//
//  InteractionListener.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/5/22.
//

import CoreGraphics
import Foundation

public class InteractionListener: Equatable {
    private let id: String

    /// The bounding box for the view the listener is attached too.
    public let boundingBox: CGRect

    /// The code that should be run if the conditions are met for the listener.
    public let action: () -> Void

    init(id: String, boundingBox: CGRect, action: @escaping () -> Void) {
        self.id = id
        self.boundingBox = boundingBox
        self.action = action
    }

    public static func == (lhs: InteractionListener, rhs: InteractionListener) -> Bool {
        lhs.id == rhs.id
    }
}

class HoverListener: InteractionListener {
    private let onHoverChanged: (Bool) -> Void
    public var isHovering = false {
        didSet {
            if oldValue != isHovering {
                onHoverChanged(isHovering)
            }
        }
    }

    init(
        id: String = "",
        boundingBox: CGRect,
        onHoverChanged: @escaping (Bool) -> Void
    ) {
        self.onHoverChanged = onHoverChanged
        super.init(id: id, boundingBox: boundingBox, action: {})
    }
}
