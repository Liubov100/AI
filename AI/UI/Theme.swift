//
//  Theme.swift
//  AI
//
//  Created by Lu on 1/17/26.
//

import SwiftUI

// MARK: - App Theme
enum AppTheme {
    // MARK: - Colors
    enum Colors {
        // Primary accent colors
        static let primaryBlue = Color.blue
        static let primaryPurple = Color.purple
        static let primaryCyan = Color.cyan
        static let primaryYellow = Color.yellow
        static let primaryOrange = Color.orange
        static let primaryPink = Color.pink
        static let primaryGreen = Color.green

        // UI Background gradients
        static func headerGradient(start: Color, end: Color) -> LinearGradient {
            LinearGradient(
                colors: [start.opacity(0.8), end.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        static func cardGradient(dark: Bool = false) -> LinearGradient {
            LinearGradient(
                colors: dark ?
                    [Color.black.opacity(0.7), Color.black.opacity(0.5)] :
                    [Color(.controlBackgroundColor), Color(.controlBackgroundColor).opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        static func borderGradient() -> LinearGradient {
            LinearGradient(
                colors: [Color.white.opacity(0.3), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    // MARK: - Typography
    enum Typography {
        static func heading(size: CGFloat = 24) -> Font {
            .system(size: size, weight: .bold)
        }

        static func title(size: CGFloat = 17) -> Font {
            .system(size: size, weight: .semibold)
        }

        static func body(size: CGFloat = 14) -> Font {
            .system(size: size, weight: .regular)
        }

        static func caption(size: CGFloat = 12) -> Font {
            .system(size: size, weight: .medium)
        }
    }

    // MARK: - Spacing
    enum Spacing {
        static let extraSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 20
    }

    // MARK: - Corner Radius
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 20
    }

    // MARK: - Shadows
    enum Shadows {
        static func standard(opacity: Double = 0.3) -> (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
            (Color.black.opacity(opacity), 5, 0, 2)
        }

        static func elevated(opacity: Double = 0.3) -> (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
            (Color.black.opacity(opacity), 15, 0, 5)
        }

        static func subtle(opacity: Double = 0.1) -> (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
            (Color.black.opacity(opacity), 3, 0, 2)
        }
    }

    // MARK: - Animations
    enum Animations {
        static let spring = Animation.spring(response: 0.4, dampingFraction: 0.7)
        static let quickSpring = Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let easeOut = Animation.easeOut(duration: 0.3)
        static let smooth = Animation.easeInOut(duration: 0.5)
    }
}

// MARK: - View Extensions
extension View {
    func standardCard(borderColor: Color = .white) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(Color(.controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(borderColor.opacity(0.2), lineWidth: 2)
            )
            .shadow(
                color: AppTheme.Shadows.subtle().color,
                radius: AppTheme.Shadows.subtle().radius,
                x: AppTheme.Shadows.subtle().x,
                y: AppTheme.Shadows.subtle().y
            )
    }

    func darkCard() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                    .fill(AppTheme.Colors.cardGradient(dark: true))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                    .stroke(AppTheme.Colors.borderGradient(), lineWidth: 1)
            )
            .shadow(
                color: AppTheme.Shadows.standard().color,
                radius: AppTheme.Shadows.standard().radius,
                x: AppTheme.Shadows.standard().x,
                y: AppTheme.Shadows.standard().y
            )
    }

    func panelStyle() -> some View {
        self
            .background(Color(.windowBackgroundColor))
            .cornerRadius(AppTheme.CornerRadius.extraLarge)
            .shadow(
                color: AppTheme.Shadows.elevated().color,
                radius: AppTheme.Shadows.elevated().radius,
                x: AppTheme.Shadows.elevated().x,
                y: AppTheme.Shadows.elevated().y
            )
    }
}

// MARK: - Reusable Components

/// A circular icon badge with gradient background
struct IconBadge: View {
    let icon: String
    let color: Color
    let size: CGFloat

    init(icon: String, color: Color, size: CGFloat = 50) {
        self.icon = icon
        self.color = color
        self.size = size
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.8), color.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: color.opacity(0.4), radius: 4)

            Image(systemName: icon)
                .font(.system(size: size * 0.45))
                .foregroundColor(.white)
        }
    }
}

/// A badge showing count with gradient background
struct CountBadge: View {
    let count: Int
    let colors: [Color]

    init(count: Int, colors: [Color] = [.red, .pink]) {
        self.count = count
        self.colors = colors
    }

    var body: some View {
        Text("\(count)")
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.white)
            .padding(7)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .shadow(color: colors.first?.opacity(0.5) ?? .clear, radius: 3)
    }
}

/// A gradient header for panels
struct PanelHeader: View {
    let title: String
    let icon: String
    let iconColor: Color
    let gradientColors: [Color]
    let onClose: () -> Void

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
            Text(title)
                .font(AppTheme.Typography.heading(size: 20))
                .foregroundColor(.white)
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(AppTheme.Colors.headerGradient(start: gradientColors[0], end: gradientColors[1]))
    }
}
