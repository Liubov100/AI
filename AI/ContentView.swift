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
            // Left Ear
            Triangle()
                .fill(Color.black)
                .frame(width: 50, height: 60)
                .offset(x: -50, y: -80)

            // Right Ear
            Triangle()
                .fill(Color.black)
                .frame(width: 50, height: 60)
                .offset(x: 50, y: -80)

            // Head
            Circle()
                .fill(Color.black)
                .frame(width: 150, height: 150)

            // Left Eye
            Circle()
                .fill(Color.green)
                .frame(width: 30, height: 40)
                .offset(x: -30, y: -10)

            // Left Pupil
            Ellipse()
                .fill(Color.black)
                .frame(width: 8, height: 30)
                .offset(x: -30, y: -10)

            // Right Eye
            Circle()
                .fill(Color.green)
                .frame(width: 30, height: 40)
                .offset(x: 30, y: -10)

            // Right Pupil
            Ellipse()
                .fill(Color.black)
                .frame(width: 8, height: 30)
                .offset(x: 30, y: -10)

            // Nose
            Triangle()
                .fill(Color.pink)
                .frame(width: 15, height: 12)
                .rotationEffect(.degrees(180))
                .offset(x: 0, y: 15)

            // Body
            Ellipse()
                .fill(Color.black)
                .frame(width: 120, height: 180)
                .offset(y: 150)

            // Tail
            Capsule()
                .fill(Color.black)
                .frame(width: 20, height: 100)
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
