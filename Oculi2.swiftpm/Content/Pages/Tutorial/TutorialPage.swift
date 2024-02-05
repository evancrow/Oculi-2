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
            return "To navigate, move your head up/down & left/right  like a cursor."
        case .tapping:
            return "Hover over an object, then pinch to tap."
        case .scrolling:
            return "Hover over an object, then use two fingers to scroll up and down."
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

    @ViewBuilder
    var content: some View {
        switch step {
        case .cursor:
            CursorTutorial {
                step = .tapping
            }
        case .tapping:
            TappingTutorial {
                step = .dragging
            }
        case .dragging:
            DraggingTutorial {
                step = .scrolling
            }
        case .scrolling:
            ScrollingTutorial {
                step = .zooming
            }
        case .zooming:
            ZoomingTutorial {
                step = .tapping
            } onComplete: {
                navigationModel.moveToNextPage(popFirst: true)
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
