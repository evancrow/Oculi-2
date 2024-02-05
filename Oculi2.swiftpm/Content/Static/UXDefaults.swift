//
//  UXDefaults.swift
//
//
//  Created by Evan Crow on 2/1/24.
//

import Foundation

public struct UXDefaults {
    /// The minimum quality allowed by `VisionModel` to recognize the face as usable.
    /// The lower the number, the less strict and less acurate the data may be.
    internal static let minimumCaptureQuality: Float = 0.3
    internal static let highCaptureQuality: Float = 0.5

    // MARK: - Cursor
    internal static let cursorShowTime: Double = 2
    internal static let cursorHeight: CGFloat = 30
    /// How much to increase the speed of the cursor by.
    /// `Width` is how much to increase `x` by and `height` for `y`.
    public static var cursorMovementMultiplier: CGSize = CGSize(width: 40, height: 40)
    
    static let maximumPageWidth: CGFloat = 600
}
