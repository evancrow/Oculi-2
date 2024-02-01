//
//  File.swift
//
//
//  Created by Evan Crow on 1/31/24.
//

import Foundation

class BlinkListener: InteractionListener {
    public let numberOfBlinks: Int

    init(
        id: String = "",
        numberOfBlinks: Int,
        boundingBox: CGRect,
        action: @escaping () -> Void
    ) {
        self.numberOfBlinks = numberOfBlinks
        super.init(id: id, boundingBox: boundingBox, action: action)
    }
}

class LongBlinkListener: InteractionListener {
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

class QuickActionListener: InteractionListener {
    public let priority: Double
    public let conditionsMet: () -> Bool
    /// If `true` the Quick Action can still be run if tracking is off.
    public var overrideIsTracking: Bool

    init(
        id: String = "",
        priority: Double,
        overrideTracking: Bool = false,
        conditionsMet: @escaping () -> Bool,
        action: @escaping () -> Void
    ) {
        self.priority = priority
        self.overrideIsTracking = overrideTracking
        self.conditionsMet = conditionsMet

        super.init(id: id, boundingBox: CGRect(), action: action)
    }
}
