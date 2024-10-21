import WatchConnectivity
import SwiftUI

class ConnectivityProvider: NSObject, ObservableObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
       
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    
    }
    
    @Published var receivedHealthData: [String: Any] = [:]  // Store received health data

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // Handle receiving health data and other messages
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            // Handle receiving health data from the watch
            self.receivedHealthData = message
            self.processHealthData(message)
        }
    }

    func processHealthData(_ message: [String: Any]) {
        if let heartRate = message["heartRate"] as? Double,
           let averageHeartRate = message["averageHeartRate"] as? Double,
           let stepCount = message["stepCount"] as? Double,
           let bodyTemperature = message["bodyTemperature"] as? Double,
           let hrv = message["hrv"] as? Double,
           let restingHeartRate = message["restingHeartRate"] as? Double,
           let oxygenSaturation = message["oxygenSaturation"] as? Double,
           let walkingHeartRateAverage = message["walkingHeartRateAverage"] as? Double,
           let sleepRecords = message["sleepRecords"] as? Int {

            // Process health data
            print("Received Health Data from watch App:")
            print("Heart Rate: \(heartRate) BPM")
            print("Average Heart Rate: \(averageHeartRate) BPM")
            print("Step Count: \(stepCount)")
            print("Body Temperature: \(bodyTemperature) °C")
            print("HRV: \(hrv) ms")
            print("Resting Heart Rate: \(restingHeartRate) BPM")
            print("Oxygen Saturation: \(oxygenSaturation) %")
            print("Walking Heart Rate Average: \(walkingHeartRateAverage) BPM")
            print("Sleep Records: \(sleepRecords)")
        }
    }
}
