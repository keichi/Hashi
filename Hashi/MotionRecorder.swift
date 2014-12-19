//
//  MotionRecorder.swift
//  Hashi
//
//  Created by Keichi Takahashi on 12/12/14.
//  Copyright (c) 2014 Keichi Takahashi. All rights reserved.
//

import Foundation

class MotionRecorder {
    var filename: String!
    var accelerometerSamples: [(Float, Float, Float)] = []
    var gyrometerSamples: [(Float, Float, Float)] = []
    var sampleCount = 0
    
    init(filename: String) {
        self.filename = filename
    }
    
    func startRecording() {
    }
    
    func stopRecording() {
        var fileBuffer = ""
        let count = min(accelerometerSamples.count, gyrometerSamples.count)
        
        for i in 0..<count {
            let (accX, accY, accZ) = accelerometerSamples[i]
            let (rotX, rotY, rotZ) = gyrometerSamples[i]

            fileBuffer += "\(accX), \(accY), \(accZ), \(rotX), \(rotY), \(rotZ)\n"
        }
        
        fileBuffer.writeToFile(filename, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
    }
    
    func addAccelerometerSample(accX: Float, accY: Float, accZ: Float) {
        accelerometerSamples.append((accX, accY, accZ))
        sampleCount += 1
    }
    
    func addGyrometerSample(rotX: Float, rotY: Float, rotZ: Float) {
        gyrometerSamples.append((rotX, rotY, rotZ))
    }
}
