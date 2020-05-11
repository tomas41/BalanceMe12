//
//  ViewController.swift
//  BalanceMe12
//
//  Created by Tomas on 11.05.20.
//  Copyright © 2020 ForzaSys AS. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var debugOutput: UILabel!
    
    var gyroService: GyroService = GyroService()
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gyroService.startGyros()
        
        self.timer = Timer(fire: Date(), interval: (1.0/2.0),
                           repeats: true, block: { (timer) in
                            let stationaryFor = self.gyroService.stationaryFor()
                            
                            guard stationaryFor != 0 else {
                                self.debugOutput.text = "Moving"
                                return
                            }

                            self.debugOutput.text = "Stationary for \(round(stationaryFor))s"
        })

        RunLoop.current.add(self.timer!, forMode: RunLoop.Mode.default)
    }
}

