//
//  EegWatchAppDelegate.swift
//  EegiOS
//
//  Created by MOHAMMED ABDUL SAQHLAIN SHAIK on 10/3/24.
//

import Spezi
import SpeziHealthKit
import HealthKit

class EegWatchAppDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: CustomHealthStandard()) {  // Use CustomHealthStandard
            if HKHealthStore.isHealthDataAvailable() {
                HealthKit {
                    CollectSample(HKQuantityType(.heartRate), deliverySetting: .background(.automatic))
                    CollectSample(HKQuantityType(.stepCount), deliverySetting: .background(.automatic))
                    CollectSample(HKQuantityType(.bodyTemperature), deliverySetting: .background(.automatic))
                    CollectSample(HKQuantityType(.heartRateVariabilitySDNN), deliverySetting: .background(.automatic))
                    CollectSample(HKQuantityType(.restingHeartRate), deliverySetting: .background(.automatic))
                    CollectSample(HKQuantityType(.oxygenSaturation), deliverySetting: .background(.automatic))
                    CollectSample(HKQuantityType(.walkingHeartRateAverage), deliverySetting: .background(.automatic))
                    CollectSample(HKCategoryType(.sleepAnalysis), deliverySetting: .background(.automatic))
                }
            }
        }
    }
}

