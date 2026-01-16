//
//  AIApp.swift
//  AI
//
//  Created by Lu on 1/16/26.
//

import SwiftUI
import FirebaseCore

@main
struct AIApp: App {
    
    init () {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
