//
//  SleepyheadApp.swift
//  Sleepyhead
//
//  Created by Marius Mathiesen on 21/02/2025.
//

import SwiftUI

@main
struct SleepyheadApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            if appState.hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(appState)
            } else {
                OnboardingView()
                    .environmentObject(appState)
            }
        }
    }
}



