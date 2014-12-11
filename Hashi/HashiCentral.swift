//
//  HashiCentral.swift
//  Hashi
//
//  Created by Keichi Takahashi on 12/6/14.
//  Copyright (c) 2014 Keichi Takahashi. All rights reserved.
//

import Foundation
import CoreBluetooth

class HashiCentral : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    let hashiServiceUUID = CBUUID(string: "312599d0-6450-4d14-8c4f-eb89d66d6d8d")
    let accelCharUUID = CBUUID(string: "e715d934-c6cf-4999-b82d-6262fadd0152")
    let gyroCharUUID = CBUUID(string: "42de3770-40cb-4ff0-8e32-13f621fba635")

    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    
    override init() {
        super.init()
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        println("Connected to peripheral \(peripheral.name)")
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("Disconnected from peripheral \(peripheral.name)")
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        println("Discovered peripheral: \(peripheral)")
        println("Advertisement data: \(advertisementData)")
        println("RSSI: \(RSSI)")
        
        self.peripheral = peripheral
        central.stopScan()
        central.connectPeripheral(peripheral, options: nil)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        switch central.state {
        case .PoweredOn:
            println("CBCentralManager is powered on")
            centralManager.scanForPeripheralsWithServices([hashiServiceUUID], options: nil)
            break
        case .PoweredOff:
            println("CBCentralManager is powered off")
            break
        case .Resetting:
            println("CBCentralManager is resetting")
            break
        case .Unauthorized:
            println("This application is not allowed to use BLE")
            break
        case .Unknown:
            // ?
            break
        case .Unsupported:
            println("This device does not support BLE")
            break
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        if error != nil {
            println("Error at didDiscoverServices: \(error)")
            return
        }
        if peripheral.services.count == 0 {
            println("No services are discovered")
            return
        }
        
        for service in peripheral.services as [CBService] {
            println("Discovered service \(service.UUID.description)")
            
            peripheral.discoverCharacteristics([accelCharUUID, gyroCharUUID], forService: service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        if error != nil {
            println("Error at didDiscoverCharacteristics: \(error)")
            return
        }
        if service.characteristics.count == 0 {
            println("No characterstics are discovered")
            return
        }
        
        for characteristic in service.characteristics as [CBCharacteristic] {
            println("Discovered characteristic \(characteristic.UUID.description)")
            
            if (characteristic.UUID.UUIDString == accelCharUUID.UUIDString) {
                println("Accelerometer characteristic found, enabling notification")
                peripheral.setNotifyValue(true, forCharacteristic: characteristic)
            } else if (characteristic.UUID.UUIDString == gyroCharUUID.UUIDString) {
                println("Gyrometer characteristic found, enabling notification")
                peripheral.setNotifyValue(true, forCharacteristic: characteristic)
            }
        }
    }
    
    private func readInt16Value(data: NSData, offset: Int) -> Int16 {
        var num = NSNumber(short: 0)
        data.getBytes(&num, range: NSRange(location: offset, length: 2))
        
        return num.shortValue
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if (characteristic.UUID.UUIDString == accelCharUUID.UUIDString) {
            let accelX = 2 * Float(readInt16Value(characteristic.value(), offset: 0)) / 32768
            let accelY = 2 * Float(readInt16Value(characteristic.value(), offset: 2)) / 32768
            let accelZ = 2 * Float(readInt16Value(characteristic.value(), offset: 4)) / 32768
            
//            println("Accel: (\(accelX), \(accelY), \(accelZ))")
        } else if (characteristic.UUID.UUIDString == gyroCharUUID.UUIDString) {
            let gyroX = 250 * Float(readInt16Value(characteristic.value(), offset: 0)) / 32768
            let gyroY = 250 * Float(readInt16Value(characteristic.value(), offset: 2)) / 32768
            let gyroZ = 250 * Float(readInt16Value(characteristic.value(), offset: 4)) / 32768
            
//            println("Gyro: (\(gyroX), \(gyroY), \(gyroZ))")
        }
    }
}
