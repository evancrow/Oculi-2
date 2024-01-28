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
        timeRemaining = timerDuration
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            self?.timeRemaining -= 1
            
            if self?.timeRemaining ?? 0 <= 0 {
                timer.invalidate()
                self?.timer = nil
            }
        }
    }
    
    init(timerDuration: Int) {
        self.timeRemaining = timerDuration
        self.timerDuration = timerDuration
    }
}
