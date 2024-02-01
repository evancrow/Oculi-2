//
//  File.swift
//
//
//  Created by Evan Crow on 1/28/24.
//

import Foundation
import SwiftUI

class TimerModel: ObservableObject {
    @Published private(set) var timeRemaining: Int

    let timerDuration: Int
    var timer: Timer?

    func start() {
        // Reset everything.
        timer?.invalidate()
        timeRemaining = timerDuration

        // Re-make the timer.
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            if self?.timeRemaining ?? 0 <= 0 {
                timer.invalidate()
            } else {
                self?.timeRemaining -= 1
            }
        }
    }

    init(timerDuration: Int) {
        self.timeRemaining = timerDuration
        self.timerDuration = timerDuration
    }
}
