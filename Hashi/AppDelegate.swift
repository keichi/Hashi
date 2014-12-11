//
//  AppDelegate.swift
//  Hashi
//
//  Created by Keichi Takahashi on 12/6/14.
//  Copyright (c) 2014 Keichi Takahashi. All rights reserved.
//

import Cocoa
import CoreBluetooth

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, HashiCentralDelegate {

    @IBOutlet weak var window: NSWindow!
    var hashiCentral: HashiCentral!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        hashiCentral = HashiCentral()
        hashiCentral.delegate = self
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func didConnectToPeripheral(peripheral: CBPeripheral, error: NSError!) {
        println("Connected to: \(peripheral.name)")
    }
    
    func didDisconnectFromPeripheral(peripheral: CBPeripheral, error: NSError!) {
        println("Disconnected from: \(peripheral.name)")
    }
    
    func didUpdateAcceleration(accX: Float, accY: Float, accZ: Float) {
        println("Acceleration: \(accX, accY, accZ)")
    }
    
    func didUpdateRotationRate(rotX: Float, rotY: Float, rotZ: Float) {
        println("Rotation Rate: \(rotX, rotY, rotZ)")
    }
}

