//
//  HashiCentralDelegate.swift
//  Hashi
//
//  Created by Keichi Takahashi on 12/11/14.
//  Copyright (c) 2014 Keichi Takahashi. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol HashiCentralDelegate : class {
    func didConnectToPeripheral(peripheral: CBPeripheral, error: NSError!)
    func didDisconnectFromPeripheral(peripheral: CBPeripheral, error: NSError!)
    func didUpdateAcceleration(accX: Float, accY: Float, accZ: Float)
    func didUpdateRotationRate(rotX: Float, rotY: Float, rotZ: Float)
}
