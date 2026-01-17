//
//  TextStyle.swift
//  AI
//
//  Created by Copilot on 1/16/26.
//

import SwiftUI

struct AppTextBackgroundModifier: ViewModifier {
    var customColor: Color?

    func body(content: Content) -> some View {
        content
            .padding(2)
            .background(customColor ?? Color.black)
            .cornerRadius(4)
    }
}

extension View {
    /// Apply the app-wide text background. By default uses black.
    func appTextBackground(_ color: Color? = nil) -> some View {
        modifier(AppTextBackgroundModifier(customColor: color))
    }
}
