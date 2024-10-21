import SwiftUI

struct ContentView: View {
    @StateObject private var connectivityProvider = ConnectivityProvider()  // Proper initialization

    var body: some View {
        ScrollView {
            VStack {
                Text("iOS App")
                    .font(.largeTitle)
                    .padding()
                
                Divider()
                    .padding()
                
                // Display health data received from the watch
                Text("Health Data from WatchOS:")
                    .font(.headline)
                
                // Conditionally display health metrics if available
                Group {
                    if let heartRate = connectivityProvider.receivedHealthData["heartRate"] as? Double {
                        Text("Heart Rate: \(heartRate, specifier: "%.0f") BPM")
                    }
                    if let averageheartRate = connectivityProvider.receivedHealthData["averageheartRate"] as? Double {
                        Text("Average Heart Rate: \(averageheartRate, specifier: "%.0f") BPM")
                    }
                    if let stepCount = connectivityProvider.receivedHealthData["stepCount"] as? Double {
                        Text("Steps: \(stepCount, specifier: "%.0f") steps")
                    }
                    if let bodyTemperature = connectivityProvider.receivedHealthData["bodyTemperature"] as? Double {
                        Text("Body Temperature: \(bodyTemperature, specifier: "%.1f") °C")
                    }
                    if let hrv = connectivityProvider.receivedHealthData["hrv"] as? Double {
                        Text("HRV: \(hrv, specifier: "%.1f") ms")
                    }
                    if let restingHeartRate = connectivityProvider.receivedHealthData["restingHeartRate"] as? Double {
                        Text("Resting Heart Rate: \(restingHeartRate, specifier: "%.0f") BPM")
                    }
                    if let oxygenSaturation = connectivityProvider.receivedHealthData["oxygenSaturation"] as? Double {
                        Text("Oxygen Saturation: \(oxygenSaturation, specifier: "%.1f") %")
                    }
                    if let walkingHeartRateAverage = connectivityProvider.receivedHealthData["walkingHeartRateAverage"] as? Double {
                        Text("Walking Heart Rate Average: \(walkingHeartRateAverage, specifier: "%.0f") BPM")
                    }
                    if let sleepRecords = connectivityProvider.receivedHealthData["sleepRecords"] as? Int {
                        Text("Sleep Records: \(sleepRecords)")
                    }
                }
                .padding()
            }
        }
    }
}
