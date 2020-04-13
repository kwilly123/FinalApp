//
//  Tempo.swift
//  MixingApp-Final-Udacity-Project
//
//  Created by Kyle Wilson on 2020-04-06.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import Foundation

struct Tempo {
    var bpm: Double
    func seconds(duration: Double = 0.25) -> Double {
        return 1.0 / self.bpm * 60.0 * 4.0 * duration
    }
}
