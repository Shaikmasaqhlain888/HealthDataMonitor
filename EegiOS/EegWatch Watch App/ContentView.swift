import SwiftUI

struct ContentView: View {
    @EnvironmentObject var connectivityProvider: WatchConnectivityProvider  // Use as EnvironmentObject
    @StateObject private var healthDataManager = HealthDataManager()  // Proper instance initialization

    var body: some View {
        ScrollView {
            VStack {
                Button("Send Health Data to iPhone") {
                    connectivityProvider.sendHealthDataToPhone(healthDataManager: healthDataManager)
                }
                .padding()

                // Use HealthDataView to display all health data
                HealthDataView(healthDataManager: healthDataManager)
            }
            .onAppear {
                healthDataManager.requestAuthorization()  // Request HealthKit authorization when the view appears
            }
        }
    }
}
