//
//  DraggingTutorial.swift
//
//
//  Created by Evan Crow on 2/3/24.
//

import SwiftUI

struct DraggingTutorial: View {
    @State private var filledSquareOffset: CGSize = .zero
    @State private var filledSquareBounds: CGRect? = nil
    @State private var emptySquareBounds: CGRect? = nil
    @State private var draggingCompleteTimer: Timer? = nil

    let onComplete: () -> Void

    var body: some View {
        ZStack {
            HStack {
                Rectangle()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(Color.Oculi.Pink)

                Spacer()
            }.onDrag(name: "Tutorial") { offset in
                filledSquareOffset = offset
                checkIfDragTutorialDone()
            }
            .offset(filledSquareOffset)
            .onViewBoundsChange { bounds in
                filledSquareBounds = bounds
            }

            HStack {
                Spacer()

                Rectangle()
                    .stroke(style: StrokeStyle(lineWidth: 10))
                    .foregroundStyle(Color.Oculi.Pink)
                    .frame(width: 150, height: 150)
            }.onViewBoundsChange { bounds in
                emptySquareBounds = bounds
            }
        }.frame(height: 150)
    }

    func checkIfDragTutorialDone() {
        if let emptySquareBounds, let filledSquareBounds {
            let filledSquareMin = CGPoint(
                x: filledSquareBounds.minX + filledSquareOffset.width,
                y: filledSquareBounds.minY + filledSquareOffset.height
            )
            let filledSquareMax = CGPoint(
                x: filledSquareBounds.maxX + filledSquareOffset.width,
                y: filledSquareBounds.maxY + filledSquareOffset.height
            )

            if emptySquareBounds.contains(filledSquareMin)
                && emptySquareBounds.contains(filledSquareMax)
            {
                draggingCompleteTimer = Timer.scheduledTimer(
                    withTimeInterval: 1,
                    repeats: false
                ) { _ in
                    onComplete()
                }
            }
        }
    }
}

#Preview {
    DraggingTutorial {}
}
