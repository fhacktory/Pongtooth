//
//  BluetoothManager.swift
//  PongToothMobile
//
//  Created by Emmanuel Furnon on 13/03/2016.
//  Copyright © 2016 Emmanuel Furnon. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothManger : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    let TRANSFER_SERVICE_UUID : String = "E20A39F4-73F5-4BC4-A12F-17D1AD07A961"
    let TRANSFER_CHARACTERISTIC_UUID : String = "08590F7E-DB05-467E-8757-72F6FAEB13D4"
    
    var centralManager : CBCentralManager!
    var discoveredPeripheral : CBPeripheral!
    var data : NSMutableData!
    
    override init()
    {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        data = NSMutableData()
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager)
    {
        switch (central.state)
        {
            case .PoweredOn :
                print("great")
                central.scanForPeripheralsWithServices([CBUUID(string: TRANSFER_SERVICE_UUID)], options: [ CBCentralManagerScanOptionAllowDuplicatesKey : NSNumber(bool: true) ])
                break
            default :
                print("fail")
                break
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber)
    {
        print("cool")
        
        if (self.discoveredPeripheral != peripheral) {
            print("peripheral")
    
            self.discoveredPeripheral = peripheral;
            self.centralManager.connectPeripheral(peripheral, options:nil);
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral)
    {
        self.centralManager.stopScan();
        self.data.length = 0
    
        peripheral.delegate = self;
        peripheral.discoverServices([CBUUID(string: TRANSFER_SERVICE_UUID)])
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?)
    {
        if (error != nil)
        {
            return;
        }
    
        for service in peripheral.services!
        {
            peripheral.discoverCharacteristics(nil, forService:service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?)
    {
        if (error != nil)
        {
            return;
        }
    
        for characteristic in service.characteristics!
        {
            if (characteristic.UUID == CBUUID(string: TRANSFER_CHARACTERISTIC_UUID))
            {
                peripheral.setNotifyValue(true, forCharacteristic:characteristic)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?)
    {
        if (error != nil)
        {
            return;
        }
        
        let stringFromData = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding)
    
        if (stringFromData == "EOM")
        {
            print(NSString(data: self.data, encoding:NSUTF8StringEncoding))
            peripheral.setNotifyValue(false, forCharacteristic:characteristic)
            self.centralManager.cancelPeripheralConnection(peripheral)
        }
    
        self.data.appendData(characteristic.value!)

        print(stringFromData)
    }
    
    
    /** The peripheral letting us know whether our subscribe/unsubscribe happened or not
    */
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic:CBCharacteristic, error: NSError?)
    {
        if ((error) != nil)
        {
            print("Error changing notification state")
        }
    
        if (characteristic.UUID != CBUUID(string: TRANSFER_CHARACTERISTIC_UUID))
        {
            return;
        }
    
        if (characteristic.isNotifying)
        {
            print("Notification began on %@", characteristic)
        }
        else
        {
            print("Notification stopped on %@", characteristic)
            self.centralManager.cancelPeripheralConnection(peripheral)
        }
    }
}
