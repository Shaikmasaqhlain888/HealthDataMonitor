//
//  EegiOSApp.swift
//  EegiOS
//
//  Created by MOHAMMED ABDUL SAQHLAIN SHAIK.
//

import SwiftUI
import Spezi
import FirebaseFirestore

@main
struct MyWatchApp: App {
    @StateObject private var connectivityProvider = ConnectivityProvider()  // Initialize WatchConnectivityProvider
    @ApplicationDelegateAdaptor(EegiOSAppDelegate.self) var appDelegate  // Spezi setup

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectivityProvider)  // Pass as environment object
                .spezi(appDelegate)  // Apply Spezi configuration
        }
    }
}
