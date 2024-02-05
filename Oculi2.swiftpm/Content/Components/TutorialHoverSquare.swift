//
//  TutorialHoverSquare.swift
//
//
//  Created by Evan Crow on 2/2/24.
//

import SwiftUI

private struct TutorialHoverSquareDefaults {
    static let size: CGFloat = 100
    static let animationDuration: Double = 3
}

struct TutorialHoverSquare: View {
    @State private var filled: Bool = false
    @State private var completeTimer: Timer? = nil
    @Binding var complete: Bool

    var body: some View {
        Rectangle()
            .foregroundStyle(filled ? Color.Oculi.Pink : Color.Oculi.Pink.opacity(0))
            .frame(
                width: TutorialHoverSquareDefaults.size,
                height: TutorialHoverSquareDefaults.size
            )
            .overlay(
                Rectangle()
                    .inset(by: 5)
                    .stroke(Color.Oculi.Pink, lineWidth: 10)
                    .frame(
                        width: TutorialHoverSquareDefaults.size,
                        height: TutorialHoverSquareDefaults.size
                    )
            )
            .onHover(name: "tutorial") { isHover in
                guard !complete else {
                    return
                }

                if !filled {
                    completeTimer = Timer.scheduledTimer(
                        withTimeInterval: TutorialHoverSquareDefaults.animationDuration,
                        repeats: false
                    ) { timer in
                        complete = true
                    }
                } else {
                    completeTimer?.invalidate()
                    completeTimer = nil
                }

                withAnimation(.linear(duration: TutorialHoverSquareDefaults.animationDuration)) {
                    filled = isHover
                }
            }
    }
}

#Preview {
    TutorialHoverSquare(complete: .constant(false))
        .environmentObject(InteractionManager())
        .environmentObject(GeometryProxyValue())
}
