//
//  GameObjectViews.swift
//  AI
//
//  Created by Lu on 1/16/26.
//

import SwiftUI

// MARK: - Shiny (Star-shaped collectible)
struct ShinyView: View {
    var body: some View {
        ZStack {
            // Shadow
            Star()
                .fill(Color.yellow.opacity(0.3))
                .frame(width: 22, height: 22)
                .offset(x: 1, y: 1)
                .blur(radius: 2)

            // Main star
            Star()
                .fill(
                    LinearGradient(
                        colors: [Color.yellow, Color.orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 20, height: 20)
                .shadow(color: .yellow.opacity(0.5), radius: 3)

            // Sparkle
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: 4, height: 4)
                .offset(x: -4, y: -4)
        }
    }
}

// MARK: - Fish
struct FishView: View {
    var body: some View {
        ZStack {
            // Shadow
            Ellipse()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 32, height: 17)
                .offset(x: 1, y: 1)
                .blur(radius: 2)

            // Body
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.8), Color.cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 30, height: 15)
                .shadow(color: .blue.opacity(0.4), radius: 2)

            // Tail
            Triangle()
                .fill(Color.blue.opacity(0.8))
                .frame(width: 10, height: 12)
                .rotationEffect(.degrees(-90))
                .offset(x: -18, y: 0)

            // Eye
            Circle()
                .fill(Color.white)
                .frame(width: 3, height: 3)
                .overlay(
                    Circle()
                        .fill(Color.black)
                        .frame(width: 1.5, height: 1.5)
                )
                .offset(x: 8, y: -2)

            // Scale details
            ForEach(0..<3) { i in
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                    .frame(width: 6, height: 6)
                    .offset(x: CGFloat(-4 + i * 5), y: 0)
            }
        }
    }
}

// MARK: - Feather
struct FeatherView: View {
    var body: some View {
        ZStack {
            // Shadow
            Capsule()
                .fill(Color.green.opacity(0.3))
                .frame(width: 6, height: 26)
                .offset(x: 1, y: 1)
                .blur(radius: 2)

            // Stem
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color.brown, Color.brown.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 2, height: 20)
                .offset(y: 2)

            // Feather vane
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [Color.green.opacity(0.9), Color.green],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 12, height: 20)
                .offset(y: -2)
                .shadow(color: .green.opacity(0.4), radius: 2)

            // Feather details
            ForEach(0..<3) { i in
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 0.5, height: 8)
                    .offset(x: CGFloat(-3 + i * 3), y: -2)
            }
        }
    }
}

// MARK: - Box
struct BoxView: View {
    var body: some View {
        ZStack {
            // Shadow
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.brown.opacity(0.3))
                .frame(width: 42, height: 42)
                .offset(x: 2, y: 2)
                .blur(radius: 3)

            // Main box
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [Color.brown.opacity(0.8), Color.brown.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
                .shadow(color: .black.opacity(0.3), radius: 3)

            // Box details (tape)
            Rectangle()
                .fill(Color.yellow.opacity(0.6))
                .frame(width: 40, height: 3)

            Rectangle()
                .fill(Color.yellow.opacity(0.6))
                .frame(width: 3, height: 40)

            // Highlight
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                .frame(width: 38, height: 38)
        }
    }
}

// MARK: - Trash Can
struct TrashCanView: View {
    var body: some View {
        ZStack {
            // Shadow
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 37, height: 52)
                .offset(x: 2, y: 2)
                .blur(radius: 3)

            // Can body
            VStack(spacing: 0) {
                // Lid
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [Color.gray, Color.gray.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 40, height: 8)

                // Body
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.gray.opacity(0.9), Color.gray.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 35, height: 40)

                    // Vertical lines
                    ForEach(0..<3) { i in
                        Rectangle()
                            .fill(Color.black.opacity(0.1))
                            .frame(width: 1, height: 40)
                            .offset(x: CGFloat(-10 + i * 10))
                    }
                }
            }
            .shadow(color: .black.opacity(0.4), radius: 3)
        }
    }
}

// MARK: - Vase
struct VaseView: View {
    var body: some View {
        ZStack {
            // Shadow
            Ellipse()
                .fill(Color.red.opacity(0.3))
                .frame(width: 32, height: 47)
                .offset(x: 2, y: 2)
                .blur(radius: 3)

            // Vase body
            ZStack {
                // Main body
                Path { path in
                    path.move(to: CGPoint(x: 15, y: 5))
                    path.addLine(to: CGPoint(x: 5, y: 30))
                    path.addCurve(
                        to: CGPoint(x: 25, y: 30),
                        control1: CGPoint(x: 5, y: 35),
                        control2: CGPoint(x: 25, y: 35)
                    )
                    path.addLine(to: CGPoint(x: 15, y: 5))
                }
                .fill(
                    LinearGradient(
                        colors: [Color.red.opacity(0.8), Color.red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 3)

                // Neck
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.red.opacity(0.9))
                    .frame(width: 8, height: 8)
                    .offset(y: -16)

                // Highlight
                Ellipse()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 8, height: 15)
                    .offset(x: -5, y: 0)
            }
        }
    }
}

// MARK: - Bird
struct BirdView: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let isFlapping = Int(timeline.date.timeIntervalSince1970 * 3) % 2 == 0

            ZStack {
                // Shadow
                Ellipse()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 32, height: 22)
                    .offset(x: 1, y: 1)
                    .blur(radius: 2)

                // Body
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [Color.gray.opacity(0.9), Color.gray.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 30, height: 20)
                    .shadow(color: .black.opacity(0.2), radius: 2)

                // Head
                Circle()
                    .fill(Color.gray.opacity(0.9))
                    .frame(width: 15, height: 15)
                    .offset(x: 10, y: -5)

                // Eye
                Circle()
                    .fill(Color.black)
                    .frame(width: 3, height: 3)
                    .offset(x: 14, y: -6)

                // Beak
                Triangle()
                    .fill(Color.orange)
                    .frame(width: 5, height: 4)
                    .rotationEffect(.degrees(90))
                    .offset(x: 18, y: -4)

                // Left Wing
                Ellipse()
                    .fill(Color.gray.opacity(0.8))
                    .frame(width: 15, height: 8)
                    .rotationEffect(.degrees(isFlapping ? -20 : 20))
                    .offset(x: -5, y: 0)
                    .animation(.easeInOut(duration: 0.3), value: isFlapping)

                // Right Wing
                Ellipse()
                    .fill(Color.gray.opacity(0.7))
                    .frame(width: 15, height: 8)
                    .rotationEffect(.degrees(isFlapping ? 20 : -20))
                    .offset(x: 5, y: 0)
                    .animation(.easeInOut(duration: 0.3), value: isFlapping)
            }
        }
    }
}

// MARK: - Star Shape
struct Star: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        let numberOfPoints = 5

        for i in 0..<numberOfPoints * 2 {
            let angle = CGFloat(i) * .pi / CGFloat(numberOfPoints) - .pi / 2
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

#Preview("All Objects") {
    VStack(spacing: 20) {
        HStack(spacing: 30) {
            ShinyView()
            FishView()
            FeatherView()
        }
        HStack(spacing: 30) {
            BoxView()
            TrashCanView()
            VaseView()
        }
        HStack(spacing: 30) {
            BirdView()
        }
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
