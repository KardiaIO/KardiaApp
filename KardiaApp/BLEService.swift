//
//  BLEService.swift
//  KardiaApp
//
//  Created by Charlie Depman on 12/29/14.
//  Copyright (c) 2014 Kardia. All rights reserved.
//

import Foundation
import CoreBluetooth

// Services & Characteristics UUIDs
let BLEServiceUUID = CBUUID(string: "713D0000-503E-4C75-BA94-3148F18D941E")
let EKGCharUUID = CBUUID(string: "713D0002-503E-4C75-BA94-3148F18D941E")

// Event names
let BLEServiceChangedStatusNotification = "kBLEServiceChangedStatusNotification"
let GotBLEDataNotification = "GotBLEData"
let charValueNotification = "CharacterValue"

class BTService: NSObject, CBPeripheralDelegate {
    var peripheral: CBPeripheral?
    var ECGData: CBCharacteristic?
    var dataPoints: [String] = []
    
    init(initWithPeripheral peripheral: CBPeripheral) {
        super.init()
        
        self.peripheral = peripheral
        self.peripheral?.delegate = self
    }
    
    deinit {
        self.reset()
    }
    
    func startDiscoveringServices() {
        self.peripheral?.discoverServices([BLEServiceUUID])
    }
    
    func reset() {
        if peripheral != nil {
            peripheral = nil
        }
        
        // Deallocating therefore send notification
        self.sendBTServiceNotificationWithIsBluetoothConnected(false)
    }
    
    // Mark: - CBPeripheralDelegate
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        let uuidsForBTService: [CBUUID] = [EKGCharUUID]
        
        if (peripheral != self.peripheral) {
            // Wrong Peripheral
            return
        }
        
        if (error != nil) {
            return
        }
        
        if ((peripheral.services == nil) || (peripheral.services.count == 0)) {
            // No Services
            return
        }
        
        for service in peripheral.services {
            if service.UUID == BLEServiceUUID {
                peripheral.discoverCharacteristics(uuidsForBTService, forService: service as CBService)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        if (peripheral != self.peripheral) {
            // Wrong Peripheral
            return
        }
        
        if (error != nil) {
            return
        }
        
        for characteristic in service.characteristics {
            //        println(characteristic)
            if characteristic.UUID == EKGCharUUID {
                self.ECGData = (characteristic as CBCharacteristic)
                peripheral.setNotifyValue(true, forCharacteristic: characteristic as CBCharacteristic)
                // Send notification that Bluetooth is connected and all required characteristics are discovered
                self.sendBTServiceNotificationWithIsBluetoothConnected(true)
            }
            
        }
    }
    
    // This function executes when the BLE device updates the value it is transmitting.
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if self.ECGData == nil {
            return
        }
        // Get the raw data from the device and type cast it to string.
        var charRawValue: NSData = self.ECGData!.value
        var charValue: String = NSString(data: charRawValue, encoding: NSUTF8StringEncoding)!
        
        // Store the latest datapoints in an array to be passed on for visualization
        dataPoints.append(charValue)
        if dataPoints.count > 15 {
            dataPoints.removeAtIndex(0)
        }
        // Pass the datapoints on via a notification.
        let passData = ["passData": dataPoints]
        let charData = ["charData": charValue]
        NSNotificationCenter.defaultCenter().postNotificationName(GotBLEDataNotification, object: self, userInfo: passData)
        NSNotificationCenter.defaultCenter().postNotificationName(charValueNotification, object: self, userInfo: charData)
    }
    
    // When Bluetooth device connection status changes, fire an event
    func sendBTServiceNotificationWithIsBluetoothConnected(isBluetoothConnected: Bool) {
        let connectionDetails = ["isConnected": isBluetoothConnected]
        NSNotificationCenter.defaultCenter().postNotificationName(BLEServiceChangedStatusNotification, object: self, userInfo: connectionDetails)
    }
    
}
