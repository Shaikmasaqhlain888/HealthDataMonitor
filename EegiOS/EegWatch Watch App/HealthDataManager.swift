import Foundation
import HealthKit
import Spezi
import SpeziHealthKit
import SwiftUI

class HealthDataManager: ObservableObject {
    private var healthStore = HKHealthStore()

    @Published var currentHeartRate: Double = 0.0
    @Published var averageHeartRate: Double = 0.0
    @Published var stepCount: Double = 0.0
    @Published var bodyTemperature: Double = 0.0
    @Published var hrv: Double = 0.0
    @Published var restingHeartRate: Double = 0.0
    @Published var oxygenSaturation: Double = 0.0
    @Published var walkingHeartRateAverage: Double = 0.0
    @Published var sleepData: [HKCategorySample] = []

    init() {
        requestAuthorization()
    }

    // Request authorization to read all required health data
    func requestAuthorization() {
        if HKHealthStore.isHealthDataAvailable() {
            let healthTypes: Set<HKSampleType> = [
                HKObjectType.quantityType(forIdentifier: .heartRate)!,
                HKObjectType.quantityType(forIdentifier: .stepCount)!,
                HKObjectType.quantityType(forIdentifier: .bodyTemperature)!,
                HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
                HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
                HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
                HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)!,
                HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
            ]
            
            healthStore.requestAuthorization(toShare: nil, read: healthTypes) { success, error in
                if success {
                    self.startObserverQueries()
                } else {
                    print("Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }

    // Start observing changes in HealthKit data
    private func startObserverQueries() {
        startHeartRateObserver()
        startStepCountObserver()
        startBodyTemperatureObserver()
        startHRVObserver()
        startRestingHeartRateObserver()
        startOxygenSaturationObserver()
        startWalkingHeartRateObserver()
        startSleepObserver()
    }

    // MARK: - Heart Rate Observer
    private func startHeartRateObserver() {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] _, _, error in
            if let error = error {
                print("Heart rate observer query failed: \(error.localizedDescription)")
                return
            }
            self?.fetchLatestHeartRateSample()
            self?.fetchAverageHeartRateForToday()
        }
        healthStore.execute(query)
    }

    // MARK: - Fetch Latest Heart Rate Sample
    private func fetchLatestHeartRateSample() {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] query, samples, error in
            if let sample = samples?.first as? HKQuantitySample {
                DispatchQueue.main.async {
                    let heartRateUnit = HKUnit(from: "count/min")
                    self?.currentHeartRate = sample.quantity.doubleValue(for: heartRateUnit)
                }
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - Fetch Average Heart Rate for Today
    private func fetchAverageHeartRateForToday() {
            let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
            let calendar = Calendar.current
            let now = Date()
            let startOfDay = calendar.startOfDay(for: now)

            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
            let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] query, samples, error in
                if let error = error {
                    print("Failed to fetch average heart rate: \(error.localizedDescription)")
                    return
                }

                guard let heartRateSamples = samples as? [HKQuantitySample], !heartRateSamples.isEmpty else {
                    print("No heart rate data available for today.")
                    return
                }

                // Calculate the average heart rate
                let totalHeartRate = heartRateSamples.reduce(0) { sum, sample in
                    sum + sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                }
                let averageHeartRate = totalHeartRate / Double(heartRateSamples.count)

                DispatchQueue.main.async {
                    self?.averageHeartRate = averageHeartRate  // Store the average heart rate
                }
            }
            healthStore.execute(query)
        }

    // MARK: - Step Count Observer and Fetch Total for Today
    private func startStepCountObserver() {
        let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let query = HKObserverQuery(sampleType: stepCountType, predicate: nil) { [weak self] _, _, error in
            if let error = error {
                print("Step count observer query failed: \(error.localizedDescription)")
                return
            }
            self?.fetchStepCountForToday()  // Fetch total steps for today
        }
        healthStore.execute(query)
    }

    private func fetchStepCountForToday() {
        let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            if let error = error {
                print("Failed to fetch step count for today: \(error.localizedDescription)")
                return
            }

            if let sum = result?.sumQuantity() {
                let stepCount = sum.doubleValue(for: HKUnit.count())
                DispatchQueue.main.async {
                    self?.stepCount = stepCount
                }
            }
        }
        healthStore.execute(query)
    }

    // MARK: - Body Temperature Observer
    private func startBodyTemperatureObserver() {
        let bodyTempType = HKObjectType.quantityType(forIdentifier: .bodyTemperature)!
        let query = HKObserverQuery(sampleType: bodyTempType, predicate: nil) { [weak self] _, _, error in
            if let error = error {
                print("Body temperature observer query failed: \(error.localizedDescription)")
                return
            }
            self?.fetchBodyTemperature()
        }
        healthStore.execute(query)
    }

    private func fetchBodyTemperature() {
        let bodyTempType = HKObjectType.quantityType(forIdentifier: .bodyTemperature)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: bodyTempType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] query, samples, error in
            if let sample = samples?.first as? HKQuantitySample {
                DispatchQueue.main.async {
                    self?.bodyTemperature = sample.quantity.doubleValue(for: HKUnit.degreeCelsius())
                }
            }
        }
        healthStore.execute(query)
    }

    // MARK: - HRV Observer
    private func startHRVObserver() {
        let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let query = HKObserverQuery(sampleType: hrvType, predicate: nil) { [weak self] _, _, error in
            if let error = error {
                print("HRV observer query failed: \(error.localizedDescription)")
                return
            }
            self?.fetchHRV()
        }
        healthStore.execute(query)
    }

    private func fetchHRV() {
        let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: hrvType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] query, samples, error in
            if let sample = samples?.first as? HKQuantitySample {
                DispatchQueue.main.async {
                    self?.hrv = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
                }
            }
        }
        healthStore.execute(query)
    }

    // MARK: - Resting Heart Rate Observer
    private func startRestingHeartRateObserver() {
        let restingHRType = HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
        let query = HKObserverQuery(sampleType: restingHRType, predicate: nil) { [weak self] _, _, error in
            if let error = error {
                print("Resting heart rate observer query failed: \(error.localizedDescription)")
                return
            }
            self?.fetchRestingHeartRate()
        }
        healthStore.execute(query)
    }

    private func fetchRestingHeartRate() {
        let restingHRType = HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: restingHRType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] query, samples, error in
            if let sample = samples?.first as? HKQuantitySample {
                DispatchQueue.main.async {
                    self?.restingHeartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                }
            }
        }
        healthStore.execute(query)
    }

    // MARK: - Oxygen Saturation Observer
    private func startOxygenSaturationObserver() {
        let oxygenSaturationType = HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!
        let query = HKObserverQuery(sampleType: oxygenSaturationType, predicate: nil) { [weak self] _, _, error in
            if let error = error {
                print("Oxygen saturation observer query failed: \(error.localizedDescription)")
                return
            }
            self?.fetchOxygenSaturation()
        }
        healthStore.execute(query)
    }

    private func fetchOxygenSaturation() {
        let oxygenSaturationType = HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: oxygenSaturationType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] query, samples, error in
            if let sample = samples?.first as? HKQuantitySample {
                DispatchQueue.main.async {
                    self?.oxygenSaturation = sample.quantity.doubleValue(for: HKUnit.percent())
                }
            }
        }
        healthStore.execute(query)
    }

    // MARK: - Walking Heart Rate Observer
    private func startWalkingHeartRateObserver() {
        let walkingHRType = HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)!
        let query = HKObserverQuery(sampleType: walkingHRType, predicate: nil) { [weak self] _, _, error in
            if let error = error {
                print("Walking heart rate observer query failed: \(error.localizedDescription)")
                return
            }
            self?.fetchWalkingHeartRateAverage()
        }
        healthStore.execute(query)
    }

    private func fetchWalkingHeartRateAverage() {
        let walkingHRType = HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: walkingHRType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] query, samples, error in
            if let sample = samples?.first as? HKQuantitySample {
                DispatchQueue.main.async {
                    self?.walkingHeartRateAverage = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                }
            }
        }
        healthStore.execute(query)
    }

    // MARK: - Sleep Data Observer
    private func startSleepObserver() {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let query = HKObserverQuery(sampleType: sleepType, predicate: nil) { [weak self] _, _, error in
            if let error = error {
                print("Sleep data observer query failed: \(error.localizedDescription)")
                return
            }
            self?.fetchSleepData()
        }
        healthStore.execute(query)
    }

    private func fetchSleepData() {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 10, sortDescriptors: [sortDescriptor]) { [weak self] query, samples, error in
            if let sleepSamples = samples as? [HKCategorySample] {
                DispatchQueue.main.async {
                    self?.sleepData = sleepSamples
                }
            }
        }
        healthStore.execute(query)
    }
}
