//
//  File.swift
//
//
//  Created by Evan Crow on 2/6/24.
//

import Foundation

class Buffer<Data> {
    let size: Int
    private var values: [Data] = []

    func enqueue(value: Data) {
        values.insert(value, at: 0)

        if values.count == size {
            dequeue()
        }
    }

    @discardableResult
    func dequeue() -> Data {
        return values.removeLast()
    }

    func peek() -> Data? {
        return values.first
    }

    func getAllValues() -> [Data] {
        return values
    }

    init(size: Int) {
        self.size = size
    }
}
