//
//  ArtboardView.swift
//
//
//  Created by Evan Crow on 2/8/24.
//

import SwiftUI

struct ArtboardView: View {
    @EnvironmentObject private var geometryProxyValue: GeometryProxyValue
    @EnvironmentObject private var interactionManager: InteractionManager
    @State private var lines: [Line] = []
    @State private var origin: CGPoint?
    @State private var dragOffset: CGSize = .zero

    var isEmpty: Bool {
        lines.count == 0
    }

    var body: some View {
        VStack(spacing: PaddingSizes._12) {
            HStack {
                Button {
                    lines = []
                } label: {
                    Text("Clear Board")
                }
                .buttonStyle(UnderlinedButtonStyle())
                .onTap(name: "clear") {
                    lines = []
                }

                Spacer()
            }

            ZStack {
                if isEmpty {
                    Text("Pinch and drag to drag to draw on the Artboard!")
                        .font(FontStyles.Body.font)
                } else {
                    Canvas { ctx, size in
                        for line in lines {
                            var path = Path()
                            path.addLines(line.points)

                            ctx.stroke(
                                path,
                                with: .color(line.color),
                                style: StrokeStyle(
                                    lineWidth: 5,
                                    lineCap: .round,
                                    lineJoin: .round
                                )
                            )
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onViewBoundsChange { bounds in
                origin = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
            }
            .onDrag(name: "Artboard", offset: $dragOffset)
            .onChange(of: dragOffset) { location in
                guard let geom = geometryProxyValue.geom, let origin = origin else {
                    return
                }

                var newPoint = CGPoint(x: location.width, y: location.height)
                newPoint.add(point: origin)

                if let lastIdx = lines.indices.last {
                    lines[lastIdx].points.append(newPoint)
                } else {
                    lines.append(Line(points: [newPoint], color: .Oculi.Button.Label))
                }
            }
            .onChange(of: interactionManager.switchToDragging) { value in
                if !value {
                    dragOffset = .zero
                    lines.append(Line(points: [], color: .Oculi.Button.Label))
                }
            }
            .background(Color.Oculi.Pink.opacity(0.3))
        }
    }
}

#Preview {
    GeometryReader { geom in
        ArtboardView()
            .environmentObject(GeometryProxyValue(geom: geom))
            .environmentObject(InteractionManager())
            .environmentObject(SpeechRecognizerModel())
            .padding(PaddingSizes._52)
    }
}
