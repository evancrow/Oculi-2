//
//  File.swift
//
//
//  Created by Evan Crow on 1/31/24.
//

import Foundation
import SwiftUI

class TapListener: InteractionListener {
    public let numberOfTaps: Int

    init(
        id: String = "",
        numberOfTaps: Int = 1,
        boundingBox: CGRect,
        action: @escaping () -> Void
    ) {
        self.numberOfTaps = numberOfTaps
        super.init(id: id, boundingBox: boundingBox, action: action)
    }
}

class LongTapListener: InteractionListener {
    public let duration: Int

    init(
        id: String = "",
        duration: Int,
        boundingBox: CGRect,
        action: @escaping () -> Void
    ) {
        self.duration = duration
        super.init(id: id, boundingBox: boundingBox, action: action)
    }
}

class ScrollListener: InteractionListener {
    public let direction: Axis
    public var distance: CGFloat = 0

    init(
        id: String = "",
        direction: Axis,
        boundingBox: CGRect
    ) {
        self.direction = direction
        super.init(id: id, boundingBox: boundingBox, action: {})
    }
}

class ZoomListener: InteractionListener {
    public var scale: Double = 1

    override init(
        id: String = "",
        boundingBox: CGRect,
        action: @escaping () -> Void
    ) {
        super.init(id: id, boundingBox: boundingBox, action: action)
    }
}
