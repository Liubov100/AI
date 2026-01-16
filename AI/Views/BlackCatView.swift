//
//  BlackCatView.swift
//  AI
//
//  Created by Lu on 1/16/26.
//

import SwiftUI

struct BlackCat: View {
    var body: some View {
        ZStack {
            // Shadow layer (bottom)
            ZStack {
                // Tail shadow
                Capsule()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 10, height: 50)
                    .rotationEffect(.degrees(45))
                    .offset(x: 42, y: 92)
                    .blur(radius: 4)

                // Body shadow
                Ellipse()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 60, height: 90)
                    .offset(x: 2, y: 77)
                    .blur(radius: 4)

                // Head shadow
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 75, height: 75)
                    .offset(x: 2, y: 2)
                    .blur(radius: 4)
            }

            // Left Ear
            Triangle()
                .fill(Color.black)
                .frame(width: 25, height: 30)
                .shadow(color: .black.opacity(0.5), radius: 5, x: 2, y: 2)
                .offset(x: -25, y: -40)

            // Right Ear
            Triangle()
                .fill(Color.black)
                .frame(width: 25, height: 30)
                .shadow(color: .black.opacity(0.5), radius: 5, x: 2, y: 2)
                .offset(x: 25, y: -40)

            // Head
            ZStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 75, height: 75)
                    .shadow(color: .black.opacity(0.6), radius: 7, x: 4, y: 4)

                // Highlight on head (top-left)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.15), Color.clear],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 40
                        )
                    )
                    .frame(width: 75, height: 75)
            }

            // Left Eye
            ZStack {
                // Eye white/glow
                Circle()
                    .fill(Color.green.opacity(0.3))
                    .frame(width: 17, height: 22)
                    .blur(radius: 1.5)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.green.opacity(0.9), Color.green],
                            center: .center,
                            startRadius: 2,
                            endRadius: 10
                        )
                    )
                    .frame(width: 15, height: 20)

                // Left Pupil
                Ellipse()
                    .fill(Color.black)
                    .frame(width: 4, height: 15)

                // Eye shine
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 2.5, height: 2.5)
                    .offset(x: -1, y: -4)
            }
            .offset(x: -15, y: -5)

            // Right Eye
            ZStack {
                // Eye white/glow
                Circle()
                    .fill(Color.green.opacity(0.3))
                    .frame(width: 17, height: 22)
                    .blur(radius: 1.5)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.green.opacity(0.9), Color.green],
                            center: .center,
                            startRadius: 2,
                            endRadius: 10
                        )
                    )
                    .frame(width: 15, height: 20)

                // Right Pupil
                Ellipse()
                    .fill(Color.black)
                    .frame(width: 4, height: 15)

                // Eye shine
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 2.5, height: 2.5)
                    .offset(x: -1, y: -4)
            }
            .offset(x: 15, y: -5)

            // Body
            ZStack {
                Ellipse()
                    .fill(Color.black)
                    .frame(width: 60, height: 90)
                    .shadow(color: .black.opacity(0.6), radius: 7, x: 4, y: 4)

                // Highlight on body (left side)
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.1), Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 60, height: 90)
            }
            .offset(y: 75)

            // Tail
            ZStack {
                Capsule()
                    .fill(Color.black)
                    .frame(width: 10, height: 50)
                    .shadow(color: .black.opacity(0.6), radius: 5, x: 2, y: 2)

                // Highlight on tail
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.15), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 10, height: 50)
            }
            .rotationEffect(.degrees(45))
            .offset(x: 40, y: 90)
        }
        .frame(width: 100, height: 200)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    BlackCat()
        .background(Color.gray.opacity(0.2))
}
