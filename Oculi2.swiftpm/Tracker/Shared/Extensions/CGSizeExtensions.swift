//
//  CGSizeExtensions.swift
//
//
//  Created by Evan Crow on 2/7/24.
//

import Foundation

extension CGSize {
    mutating func add(size: CGSize) {
        self = CGSize(width: self.width + size.width, height: self.height + size.height)
    }

    mutating func apply(modifier: (CGFloat) -> CGFloat) {
        self = CGSize(width: modifier(self.width), height: modifier(self.height))
    }
}
