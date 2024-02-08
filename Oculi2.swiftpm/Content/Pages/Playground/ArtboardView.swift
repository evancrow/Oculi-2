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

    var isEmpty: Bool {
        lines.count == 0
    }

    var body: some View {
        VStack(spacing: PaddingSizes._52) {
            HStack {
                Button {
                    lines = []
                } label: {
                    Text("Clear Board")
                }
                .buttonStyle(DefaultButtonStyle())
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
            .onDrag(name: "Artboard") { location in
                guard let geom = geometryProxyValue.geom else {
                    return
                }

                var origin = CGPoint(
                    x: geom.size.width / 2,
                    y: geom.size.width / 2
                )
                origin.add(point: CGPoint(x: location.width, y: location.height))

                if let lastIdx = lines.indices.last {
                    lines[lastIdx].points.append(origin)
                } else {
                    lines.append(Line(points: [origin], color: .Oculi.Pink))
                }
            }
            .onChange(of: interactionManager.switchToDragging) { value in
                if !value {
                    lines.append(Line(points: [], color: .Oculi.Pink))
                }
            }
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
