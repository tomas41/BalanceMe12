//
//  GyroService.swift
//  BalanceMe12
//
//  Created by Tomas on 11.05.20.
//  Copyright © 2020 ForzaSys AS. All rights reserved.
//

import Foundation
import CoreMotion

enum PhoneStatus {
    case stationary
    case moving
}

class GyroService {
    var motion = CMMotionManager()
    var timer: Timer?
    var stationarySince: DispatchTime;
    var moving: Bool = false
    
    init() {
        self.stationarySince = DispatchTime.now()
        self.moving = false
    }

    func startGyros() {
        print("Starting gyros")
        
        if motion.isGyroAvailable {
            self.motion.gyroUpdateInterval = 1.0 / 60.0
            self.motion.startGyroUpdates()
            
            // Configure a timer to fetch the accelerometer data.
            self.timer = Timer(fire: Date(), interval: (1.0/2.0),
                               repeats: true, block: { (timer) in
                                // Get the gyro data.
                                if let data = self.motion.gyroData {
                                    let x = data.rotationRate.x
                                    let y = data.rotationRate.y
                                    let z = data.rotationRate.z

                                    // Use the gyroscope data in your app.
                                    if (abs(x) < 0.05 && abs(y) < 0.05 && abs(z) < 0.05) {
                                        let now = DispatchTime.now()
                                        if self.moving {
                                            self.stationarySince = now
                                            self.moving = false
                                        }

                                        let stationaryFor = now.uptimeNanoseconds - self.stationarySince.uptimeNanoseconds
                                        print("Phone stationary for \(Double(stationaryFor) / 1e9) seconds")
                                    } else {
                                        self.moving = true
                                        print("Phone is moving \(x) \(y) \(z)")
                                    }
                                }
            })
            
            // Add the timer to the current run loop.
            RunLoop.current.add(self.timer!, forMode: RunLoop.Mode.default)
        }
    }
    
    func stationaryFor() -> Double {
        guard !self.moving else {
            return 0;
        }

        let now = DispatchTime.now()
        let stationaryFor = now.uptimeNanoseconds - self.stationarySince.uptimeNanoseconds

        return Double(stationaryFor) / 1e9
    }
    
    func stopGyros() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
            
            self.motion.stopGyroUpdates()
        }
    }
}
