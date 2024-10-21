//
//  CustomHealthStandard.swift
//  EegiOS
//
//  Created by MOHAMMED ABDUL SAQHLAIN SHAIK on 10/3/24.
//

import Spezi
import SpeziHealthKit

// Define a custom standard that conforms to both Standard and HealthKitConstraint
actor CustomHealthStandard: Standard, HealthKitConstraint {
    func add(sample: HKSample) async {
        
    }
    
    func remove(sample: HKDeletedObject) async {
        
    }
    
    // You can add any custom methods or properties here if needed.
}
