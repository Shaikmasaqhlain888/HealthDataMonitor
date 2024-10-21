import SwiftUI

struct HealthDataView: View {
    @ObservedObject var healthDataManager: HealthDataManager

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Health Data Overview")
                    .font(.title)
                    .padding()

                Group {
                    Text("Heart Rate: \(healthDataManager.currentHeartRate, specifier: "%.0f") BPM")
                    Text("Average Heart Rate (Today): \(healthDataManager.averageHeartRate, specifier: "%.0f") BPM")
                    Text("Steps: \(healthDataManager.stepCount, specifier: "%.0f") steps")
                    Text("Body Temperature: \(healthDataManager.bodyTemperature, specifier: "%.1f") °C")
                    Text("HRV: \(healthDataManager.hrv, specifier: "%.1f") ms")
                    Text("Resting Heart Rate: \(healthDataManager.restingHeartRate, specifier: "%.0f") BPM")
                    Text("Oxygen Saturation: \(healthDataManager.oxygenSaturation, specifier: "%.1f") %")
                    Text("Walking Heart Rate Average: \(healthDataManager.walkingHeartRateAverage, specifier: "%.0f") BPM")
                }

                if !healthDataManager.sleepData.isEmpty {
                    Text("Sleep Data: \(healthDataManager.sleepData.count) records")
                } else {
                    Text("No sleep data available")
                }
            }
            .padding()
        }
    }
}
