//
//  File.swift
//
//
//  Created by Evan Crow on 1/26/24.
//

import Foundation

extension CGPoint {
    func calculateDistance(to point: CGPoint) -> CGFloat {
        sqrt(pow((point.x - self.x), 2) + pow((point.y - self.y), 2))
    }

    mutating func add(point: CGPoint) {
        self = CGPoint(x: self.x + point.x, y: self.y + point.y)
    }

    func apply(modifier: (CGFloat) -> CGFloat) -> CGPoint {
        return CGPoint(x: modifier(self.x), y: modifier(self.y))
    }
}
