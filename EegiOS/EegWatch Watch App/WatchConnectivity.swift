import WatchConnectivity
import SwiftUI

class WatchConnectivityProvider: NSObject, ObservableObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
    }
    
    @Published var receivedHealthData: [String: Any] = [:]
    private var sendTimer : Timer?// Store received health data

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
        startSendTimer()
    }
    
    private func startSendTimer() {
            sendTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.sendHealthDataToPhone(healthDataManager: HealthDataManager())
            }
        }
    
    // Invalidate the timer when it's no longer needed
    deinit {
        sendTimer?.invalidate()
    }
    
    

    func sendHealthDataToPhone(healthDataManager: HealthDataManager) {
        if WCSession.default.isReachable {
            let healthData: [String: Any] = [
                "heartRate": healthDataManager.currentHeartRate,
                "averageheartRate": healthDataManager.averageHeartRate,
                "stepCount": healthDataManager.stepCount,
                "bodyTemperature": healthDataManager.bodyTemperature,
                "hrv": healthDataManager.hrv,
                "restingHeartRate": healthDataManager.restingHeartRate,
                "oxygenSaturation": healthDataManager.oxygenSaturation,
                "walkingHeartRateAverage": healthDataManager.walkingHeartRateAverage,
                "sleepRecords": healthDataManager.sleepData.count
            ]
            
            WCSession.default.sendMessage(healthData, replyHandler: nil) { error in
                print("Error sending health data: \(error.localizedDescription)")
            }
        } else {
            print("iPhone is not reachable")
        }
    }

    // Handle receiving health data and other messages
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            // Handle receiving health data from the watch
            self.receivedHealthData = message
        }
    }
    
}
