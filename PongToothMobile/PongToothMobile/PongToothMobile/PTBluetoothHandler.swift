//
//  PTBluetoothHandler.swift
//  PongToothMobile
//
//  Created by Emmanuel Furnon on 12/03/2016.
//  Copyright © 2016 Emmanuel Furnon. All rights reserved.
//

import Foundation
import CoreBluetooth

class PTBluetoothHandler : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate
{
    let kServiceUUID : String = "312700E2-E798-4D5C-8DCF-49908332DF9F"
    let kCharacteristicUUID : String = "FFA28CDE-6525-4489-801C-1C060CAC9767"
    
    var peripheral : CBPeripheral?
    
    override init() {
        super.init()
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager)
    {
        switch (central.state)
        {
            case .PoweredOn :
                print("great")
                central.scanForPeripheralsWithServices([CBUUID(string: kServiceUUID)], options: [ CBCentralManagerScanOptionAllowDuplicatesKey : NSNumber(bool: true) ])
                break
            default :
                print("fail")
                break
        }
    }
    
    // Check out the discovered peripherals
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString
        
        if (nameOfDeviceFound == "com.fhacktory.pongtooth") {
            // Stop scanning
            print("connect")
            
            central.stopScan()
            self.peripheral = peripheral
            central.connectPeripheral(self.peripheral!, options: nil)
        }
    }
    
    // Discover services of the peripheral
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Discovering peripheral services")
        print(self.peripheral?.state == CBPeripheralState.Connected)
        self.peripheral?.delegate = self
        self.peripheral?.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("error")
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if (error != nil)
        {
            print(error)
        }
        else
        {
            for service in (self.peripheral?.services)!
            {
                let thisService = service as CBService
                
                self.peripheral?.discoverCharacteristics(nil, forService: thisService)
                
                // Uncomment to print list of UUIDs
                print(thisService.UUID)
            }
        }
    }
    
    // Enable notification and sensor for each characteristic of valid service
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        print("Enabling sensors")
        
        // check the uuid of each characteristic to find config and data characteristics
        for charateristic in service.characteristics! {
            print(charateristic.UUID)
            
            if (charateristic.UUID == CBUUID(string:"DA18")) {
                print(charateristic.properties);
                self.peripheral?.setNotifyValue(true, forCharacteristic: charateristic);
            }

            let thisCharacteristic = charateristic as CBCharacteristic
            // check for data characteristic
            //if thisCharacteristic.UUID == kCharacteristicUUID {
                // Enable Sensor Notification
                self.peripheral?.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            
            let dictionaryExample : [String:AnyObject] = ["ok":"ok"] // image should be either NSData or empty
            let dataExample : NSData = NSKeyedArchiver.archivedDataWithRootObject(dictionaryExample)
            
                peripheral.writeValue(dataExample, forCharacteristic: thisCharacteristic, type: CBCharacteristicWriteType.WithoutResponse)
            //}
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        print("Connected")
        
        let dataBytes = characteristic.value
        print(dataBytes)
        print(NSString(data: dataBytes!, encoding: NSUTF8StringEncoding))
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error:NSError?) {
        print("did write")
    }
}