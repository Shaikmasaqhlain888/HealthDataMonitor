//
//  EegWatchApp.swift
//  EegWatch Watch App
//
//  Created by MOHAMMED ABDUL SAQHLAIN SHAIK on 9/5/24.
//
import SwiftUI
import Spezi

@main
struct MyWatchApp_WatchApp: App {
    @StateObject private var connectivityProvider = WatchConnectivityProvider()  // Initialize WatchConnectivityProvider
    @ApplicationDelegateAdaptor(EegWatchAppDelegate.self) var appDelegate  // Spezi setup

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(connectivityProvider)  // Pass as environment object
                .spezi(appDelegate)  // Apply Spezi configuration
        }
    }
}
