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
    
    @IBOutlet weak var lblAccX: NSTextField!
    @IBOutlet weak var lblAccY: NSTextField!
    @IBOutlet weak var lblAccZ: NSTextField!
    
    @IBOutlet weak var lblRotX: NSTextField!
    @IBOutlet weak var lblRotY: NSTextField!
    @IBOutlet weak var lblRotZ: NSTextField!
    
    @IBOutlet weak var lblConnectionStatus: NSTextField!
    @IBOutlet weak var lblSampleCount: NSTextField!
    @IBOutlet weak var txtOutputPath: NSTextField!
    
    @IBOutlet weak var btnRecord: NSButton!
    @IBOutlet weak var btnStop: NSButton!
    
    var hashiCentral: HashiCentral!
    var motionRecorder: MotionRecorder!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        hashiCentral = HashiCentral()
        hashiCentral.delegate = self
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func didConnectToPeripheral(peripheral: CBPeripheral, error: NSError!) {
        lblConnectionStatus.stringValue = "Connected"
        lblConnectionStatus.textColor = NSColor.greenColor()
    }
    
    func didDisconnectFromPeripheral(peripheral: CBPeripheral, error: NSError!) {
        lblConnectionStatus.stringValue = "Disconnected"
        lblConnectionStatus.textColor = NSColor.redColor()
    }
    
    private func formatFloatValue(value: Float) -> String {
        return NSString(format: "%.3f", value)
    }
    
    func didUpdateAcceleration(accX: Float, accY: Float, accZ: Float) {
        lblAccX.stringValue = NSString(format: "%.3f g", accX)
        lblAccY.stringValue = NSString(format: "%.3f g", accY)
        lblAccZ.stringValue = NSString(format: "%.3f g", accZ)
        
        motionRecorder?.addAccelerometerSample(accX, accY: accY, accZ: accZ)
        if let sampleCount = motionRecorder?.sampleCount {
            lblSampleCount.stringValue = "\(sampleCount) Samples"
        }
    }
    
    func didUpdateRotationRate(rotX: Float, rotY: Float, rotZ: Float) {
        lblRotX.stringValue = NSString(format: "%.3f deg/s", rotX)
        lblRotY.stringValue = NSString(format: "%.3f deg/s", rotY)
        lblRotZ.stringValue = NSString(format: "%.3f deg/s", rotZ)
        
        motionRecorder?.addGyrometerSample(rotX, rotY: rotY, rotZ: rotZ)
    }
    
    private func getCurrentOutputFilename() -> String {
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss'.csv'"
        let filename = formatter.stringFromDate(NSDate())
        
        return txtOutputPath.stringValue.stringByAppendingPathComponent(filename)
    }
    
    @IBAction func btnRecordPressed(sender: NSButton) {
        var isDir: ObjCBool = ObjCBool(false)
        
        if (NSFileManager.defaultManager().fileExistsAtPath(txtOutputPath.stringValue, isDirectory: &isDir)) {
            btnRecord.enabled = false
            btnStop.enabled = true
            
            if (isDir) {
                motionRecorder = MotionRecorder(filename: getCurrentOutputFilename())
                motionRecorder.startRecording()
            }
        }
    }
    
    @IBAction func btnStopPressed(sender: NSButton) {
        btnRecord.enabled = true
        btnStop.enabled = false
        
        motionRecorder.stopRecording()
        motionRecorder = nil
        lblSampleCount.stringValue = "0 Samples"
    }
    
    @IBAction func btnSelectOutputPressed(sender: NSButton) {
        let dialog = NSOpenPanel()
        dialog.canChooseDirectories = true
        dialog.canChooseFiles = false
        dialog.canCreateDirectories = true
        dialog.allowsMultipleSelection = false
        dialog.worksWhenModal = true
        dialog.prompt = "Select"
        
        if (dialog.runModal() == NSOKButton) {
            if let url = dialog.directoryURL {
                txtOutputPath.stringValue = url.path!
            }
        }
    }
}

