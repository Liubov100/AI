//
//  ContentView.swift
//  AI
//
//  Created by Lu on 1/16/26.
//

import SwiftUI

struct ContentView: View {
    @State private var catPosition = CGPoint(x: 0, y: 0)

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            BlackCat()
                .offset(x: catPosition.x, y: catPosition.y)
        }
        .focusable()
        .onKeyPress(characters: .alphanumerics) { keyPress in
            handleCharacterPress(keyPress.characters)
            return .handled
        }
        .onKeyPress(keys: [.upArrow, .downArrow, .leftArrow, .rightArrow]) { keyPress in
            handleArrowPress(keyPress.key)
            return .handled
        }
    }

    func handleCharacterPress(_ characters: String) {
        let moveAmount: CGFloat = 20

        switch characters.lowercased() {
        case "w":
            catPosition.y -= moveAmount
        case "s":
            catPosition.y += moveAmount
        case "a":
            catPosition.x -= moveAmount
        case "d":
            catPosition.x += moveAmount
        default:
            break
        }
    }

    func handleArrowPress(_ key: KeyEquivalent) {
        let moveAmount: CGFloat = 20

        switch key {
        case .upArrow:
            catPosition.y -= moveAmount
        case .downArrow:
            catPosition.y += moveAmount
        case .leftArrow:
            catPosition.x -= moveAmount
        case .rightArrow:
            catPosition.x += moveAmount
        default:
            break
        }
    }
}

struct BlackCat: View {
    var body: some View {
        ZStack {
            // Shadow layer (bottom)
            ZStack {
                // Tail shadow
                Capsule()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 20, height: 100)
                    .rotationEffect(.degrees(45))
                    .offset(x: 85, y: 185)
                    .blur(radius: 8)

                // Body shadow
                Ellipse()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 120, height: 180)
                    .offset(x: 5, y: 155)
                    .blur(radius: 8)

                // Head shadow
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 150, height: 150)
                    .offset(x: 5, y: 5)
                    .blur(radius: 8)
            }

            // Left Ear
            ZStack {
                Triangle()
                    .fill(Color.black)
                    .frame(width: 50, height: 60)
                    .shadow(color: .black.opacity(0.5), radius: 10, x: 5, y: 5)

                // Inner ear (lighter for depth)
                Triangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 25, height: 30)
                    .offset(y: 5)
            }
            .offset(x: -50, y: -80)

            // Right Ear
            ZStack {
                Triangle()
                    .fill(Color.black)
                    .frame(width: 50, height: 60)
                    .shadow(color: .black.opacity(0.5), radius: 10, x: 5, y: 5)

                // Inner ear (lighter for depth)
                Triangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 25, height: 30)
                    .offset(y: 5)
            }
            .offset(x: 50, y: -80)

            // Head
            ZStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 150, height: 150)
                    .shadow(color: .black.opacity(0.6), radius: 15, x: 8, y: 8)

                // Highlight on head (top-left)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.15), Color.clear],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 150, height: 150)
            }

            // Left Eye
            ZStack {
                // Eye white/glow
                Circle()
                    .fill(Color.green.opacity(0.3))
                    .frame(width: 35, height: 45)
                    .blur(radius: 3)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.green.opacity(0.9), Color.green],
                            center: .center,
                            startRadius: 5,
                            endRadius: 20
                        )
                    )
                    .frame(width: 30, height: 40)

                // Left Pupil
                Ellipse()
                    .fill(Color.black)
                    .frame(width: 8, height: 30)

                // Eye shine
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 5, height: 5)
                    .offset(x: -2, y: -8)
            }
            .offset(x: -30, y: -10)

            // Right Eye
            ZStack {
                // Eye white/glow
                Circle()
                    .fill(Color.green.opacity(0.3))
                    .frame(width: 35, height: 45)
                    .blur(radius: 3)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.green.opacity(0.9), Color.green],
                            center: .center,
                            startRadius: 5,
                            endRadius: 20
                        )
                    )
                    .frame(width: 30, height: 40)

                // Right Pupil
                Ellipse()
                    .fill(Color.black)
                    .frame(width: 8, height: 30)

                // Eye shine
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 5, height: 5)
                    .offset(x: -2, y: -8)
            }
            .offset(x: 30, y: -10)

            // Nose
            ZStack {
                Triangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.pink.opacity(0.8), Color.pink],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 15, height: 12)
                    .rotationEffect(.degrees(180))
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
            }
            .offset(x: 0, y: 15)

            // Body
            ZStack {
                Ellipse()
                    .fill(Color.black)
                    .frame(width: 120, height: 180)
                    .shadow(color: .black.opacity(0.6), radius: 15, x: 8, y: 8)

                // Highlight on body (left side)
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.1), Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 120, height: 180)
            }
            .offset(y: 150)

            // Tail
            ZStack {
                Capsule()
                    .fill(Color.black)
                    .frame(width: 20, height: 100)
                    .shadow(color: .black.opacity(0.6), radius: 10, x: 5, y: 5)

                // Highlight on tail
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.15), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 20, height: 100)
            }
            .rotationEffect(.degrees(45))
            .offset(x: 80, y: 180)
        }
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
    ContentView()
}
