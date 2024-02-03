//
//  CursorTutorial.swift
//
//
//  Created by Evan Crow on 2/3/24.
//

import SwiftUI

struct CursorTutorial: View {
    @State private var cursorSquareOneDone = false
    @State private var cursorSquareTwoDone = false
    @State private var cursorCompleteTimer: Timer? = nil

    let onComplete: () -> Void

    var body: some View {
        HStack {
            TutorialHoverSquare(complete: $cursorSquareOneDone)
            Spacer()
            TutorialHoverSquare(complete: $cursorSquareTwoDone)
        }
        .frame(height: 100)
        .onChange(of: cursorSquareOneDone) { _ in
            checkIfCursorTutorialDone()
        }.onChange(of: cursorSquareTwoDone) { _ in
            checkIfCursorTutorialDone()
        }
    }

    func checkIfCursorTutorialDone() {
        if cursorSquareOneDone && cursorSquareTwoDone {
            cursorCompleteTimer = Timer.scheduledTimer(
                withTimeInterval: 1,
                repeats: false
            ) { _ in
                onComplete()
            }
        }
    }
}

#Preview {
    CursorTutorial {}
}
