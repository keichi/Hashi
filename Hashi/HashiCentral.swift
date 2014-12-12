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
    private let hashiServiceUUID = CBUUID(string: "312599d0-6450-4d14-8c4f-eb89d66d6d8d")
    private let accelCharUUID = CBUUID(string: "e715d934-c6cf-4999-b82d-6262fadd0152")
    private let gyroCharUUID = CBUUID(string: "42de3770-40cb-4ff0-8e32-13f621fba635")

    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    
    weak var delegate: HashiCentralDelegate!
    
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
        delegate?.didDisconnectFromPeripheral(peripheral, error: error)
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
            println("CBCentralManager state is unknwon")
            break
        case .Unsupported:
            println("This device does not support BLE")
            break
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        if error != nil {
            delegate?.didConnectToPeripheral(peripheral, error: error)
            return
        }
        if peripheral.services.count == 0 {
            let err = NSError(domain: "net.keichi.HashiCentral.NoService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No services are discovered"])
            delegate?.didConnectToPeripheral(peripheral, error: err)
            return
        }
        
        for service in peripheral.services as [CBService] {
            println("Discovered service \(service.UUID.description)")
            
            peripheral.discoverCharacteristics([accelCharUUID, gyroCharUUID], forService: service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        if error != nil {
            delegate?.didConnectToPeripheral(peripheral, error: error)
            return
        }
        if service.characteristics.count == 0 {
            let err = NSError(domain: "net.keichi.HashiCentral.NoCharacteristic", code: -1, userInfo: [NSLocalizedDescriptionKey: "No characteristics are discovered"])
            delegate?.didConnectToPeripheral(peripheral, error: err)
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
            
            delegate?.didConnectToPeripheral(peripheral, error: nil)
        }
    }
    
    private func getInt16FromRaw(data: NSData, offset: Int) -> Int16 {
        var val: Int16 = 0
        data.getBytes(&val, range: NSRange(location: offset, length: 2))
        
        return val
    }
    
    private func getAccelerationFromRaw(data: NSData) -> (Float, Float, Float) {
        let accX = 2 * Float(getInt16FromRaw(data, offset: 0)) / 32768
        let accY = 2 * Float(getInt16FromRaw(data, offset: 2)) / 32768
        let accZ = 2 * Float(getInt16FromRaw(data, offset: 4)) / 32768
        
        return (accX, accY, accZ)
    }
    
    private func getRotationRateFromRaw(data: NSData) -> (Float, Float, Float) {
        let rotX = 250 * Float(getInt16FromRaw(data, offset: 0)) / 32768
        let rotY = 250 * Float(getInt16FromRaw(data, offset: 2)) / 32768
        let rotZ = 250 * Float(getInt16FromRaw(data, offset: 4)) / 32768
        
        return (rotX, rotY, rotZ)
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if (characteristic.UUID.UUIDString == accelCharUUID.UUIDString) {
            let (accX, accY, accZ) = getAccelerationFromRaw(characteristic.value())
            delegate?.didUpdateAcceleration(accX, accY: accY, accZ: accZ)
        } else if (characteristic.UUID.UUIDString == gyroCharUUID.UUIDString) {
            let (rotX, rotY, rotZ) = getRotationRateFromRaw(characteristic.value())
            delegate?.didUpdateRotationRate(rotX, rotY: rotY, rotZ: rotZ)
        }
    }
}
