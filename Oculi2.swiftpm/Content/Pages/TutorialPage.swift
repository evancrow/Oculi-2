//
//  TutorialPage.swift
//
//
//  Created by Evan Crow on 1/28/24.
//

import MapKit
import SwiftUI

enum TutorialStep: String {
    case cursor = "Cursor"
    case tapping = "Tapping"
    case scrolling = "Scrolling"
    case dragging = "Dragging"
    case zooming = "Zooming"

    var title: String {
        switch self {
        case .cursor:
            return "Getting Around"
        case .tapping:
            return "Tapping"
        case .scrolling:
            return "Scrolling"
        case .dragging:
            return "Dragging"
        case .zooming:
            return "Zooming"
        }
    }

    var subtitle: String {
        switch self {
        case .cursor:
            return "To navigate, point and move your index finger like a cursor."
        case .tapping:
            return "Hover over an object, then pinch to tap."
        case .scrolling:
            return "Use two fingers to scroll up and down."
        case .dragging:
            return "Pinch and move your fingers to drag objects."
        case .zooming:
            return "Double tap to zoom in and out."
        }
    }

    var callToAction: Text {
        switch self {
        case .tapping, .scrolling:
            return Text("To move on, tap ") + Text("Next Page.").italic()
        case .cursor:
            return Text(
                "Try moving to each circle on the page.")
        case .dragging:
            return Text("Drag the filled square to complete the shape.")
        case .zooming:
            return Text("To finish the tutorial, tap ") + Text("Finish Tutorial.").italic()
        }
    }
}

struct TutorialPage: View {
    @EnvironmentObject var navigationModel: NavigationModel
    @State var step: TutorialStep = .cursor

    // Cursor.
    @State private var cursorSquareOneDone = false
    @State private var cursorSquareTwoDone = false
    @State private var cursorCompleteTimer: Timer? = nil

    // Tapping.
    @State private var oneTap = false
    @State private var twoTap = false
    @State private var longTap = false

    // Dragging.
    @State private var filledSquareOffset: CGSize = .zero
    @State private var filledSquareBounds: CGRect? = nil
    @State private var emptySquareBounds: CGRect? = nil
    @State private var draggingCompleteTimer: Timer? = nil

    // Zoom.
    @State private var scale: Double = 1

    @ViewBuilder
    var content: some View {
        switch step {
        case .cursor:
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
        case .tapping:
            VStack(spacing: PaddingSizes._52) {
                Button {
                    oneTap.toggle()
                } label: {
                    Text(oneTap ? "Tap - Tapped!" : "Tap")
                }
                .buttonStyle(DefaultButtonStyle())
                .onTap(name: "tap") {
                    oneTap.toggle()
                }

                Button {
                    twoTap.toggle()
                } label: {
                    Text(twoTap ? "Two Taps - Tapped!" : "Two Taps")
                }
                .buttonStyle(DefaultButtonStyle())
                .onTap(name: "two-taps") {
                    twoTap.toggle()
                }

                Button {
                    longTap.toggle()
                } label: {
                    Text(longTap ? "Long Tap - Tapped!" : "Long Tap")
                }
                .buttonStyle(DefaultButtonStyle())
                .onLongTap(name: "long-tap") {
                    longTap.toggle()
                }

                Button {
                    step = .scrolling
                } label: {
                    Text("Next Page")
                }.buttonStyle(DefaultButtonStyle())
            }
        case .scrolling:
            VStack(spacing: PaddingSizes._52) {
                ScrollView {
                    LinearGradient(colors: [.blue, .red], startPoint: .top, endPoint: .bottom)
                        .frame(maxWidth: .infinity, idealHeight: 1500)
                }.followScroll(name: "tutorial", direction: .vertical)

                Button {
                    step = .zooming
                } label: {
                    Text("Next Page")
                }.buttonStyle(DefaultButtonStyle())
            }
        case .dragging:
            ZStack {
                HStack {
                    Rectangle()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(Color.Oculi.Pink)

                    Spacer()
                }.onDrag(name: "Tutorial") { offset in
                    filledSquareOffset = offset
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
            }
            .frame(height: 150)
            .onChange(of: cursorSquareOneDone) { _ in
                checkIfCursorTutorialDone()
            }.onChange(of: cursorSquareTwoDone) { _ in
                checkIfCursorTutorialDone()
            }
        case .zooming:
            VStack(spacing: PaddingSizes._52) {
                VStack(spacing: PaddingSizes._12) {
                    Image("Yosemite")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)

                    Text("A cool photo I took of the Yosemite valley!")
                        .font(FontStyles.Body2.font)
                        .italic()
                }
                .clipShape(Rectangle())
                .frame(maxWidth: 500)

                VStack(spacing: PaddingSizes._12) {
                    Button {
                        navigationModel.moveToNextPage(popFirst: true)
                    } label: {
                        Text("Finish Tutorial")
                    }.buttonStyle(DefaultButtonStyle())

                    Button {
                        step = .tapping
                    } label: {
                        Text("Restart")
                    }.buttonStyle(UnderlinedButtonStyle())
                }
            }
        }
    }

    var body: some View {
        PageContainer {
            VStack(spacing: PaddingSizes._52) {
                VStack(spacing: PaddingSizes._6) {
                    Text(step.title)
                        .font(FontStyles.Title.font)

                    Text(step.subtitle)
                        .font(FontStyles.Body.font)

                    step.callToAction
                        .font(FontStyles.Body.font)
                }

                content

                Button {
                    navigationModel.moveToNextPage(popFirst: true)
                } label: {
                    Text("Skip")
                }.buttonStyle(UnderlinedButtonStyle())
            }
        }
    }

    func checkIfCursorTutorialDone() {
        if cursorSquareOneDone && cursorSquareTwoDone {
            cursorCompleteTimer = Timer.scheduledTimer(
                withTimeInterval: 1,
                repeats: false
            ) { _ in
                step = .tapping
            }
        }
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
                    step = .scrolling
                }
            }
        }
    }
}

#Preview {
    TutorialPage(step: .cursor)
        .environmentObject(NavigationModel())
        .environmentObject(InteractionManager())
        .environmentObject(GeometryProxyValue())
        .padding(PaddingSizes._52)
}

#Preview {
    TutorialPage(step: .tapping)
        .environmentObject(NavigationModel())
        .environmentObject(InteractionManager())
        .environmentObject(GeometryProxyValue())
        .padding(PaddingSizes._52)
}

#Preview {
    TutorialPage(step: .dragging)
        .environmentObject(NavigationModel())
        .environmentObject(InteractionManager())
        .environmentObject(GeometryProxyValue())
        .padding(PaddingSizes._52)
}

#Preview {
    TutorialPage(step: .scrolling)
        .environmentObject(NavigationModel())
        .environmentObject(InteractionManager())
        .environmentObject(GeometryProxyValue())
        .padding(PaddingSizes._52)
}

#Preview {
    TutorialPage(step: .zooming)
        .environmentObject(NavigationModel())
        .environmentObject(InteractionManager())
        .environmentObject(GeometryProxyValue())
        .padding(PaddingSizes._52)
}
