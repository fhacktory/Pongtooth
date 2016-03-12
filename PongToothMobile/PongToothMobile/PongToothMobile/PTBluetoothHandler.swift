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
                central.scanForPeripheralsWithServices([CBUUID(string: kServiceUUID)], options: nil)
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
            
            self.peripheral = peripheral
            central.stopScan()
            central.connectPeripheral(self.peripheral!, options: nil)
        }
    }
    
    // Discover services of the peripheral
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Discovering peripheral services")
        self.peripheral!.discoverServices(nil)
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if (error != nil)
        {
            print(error)
        }
        else
        {
            for service in peripheral.services!
            {
                let thisService = service as CBService
                if service.UUID == kServiceUUID
                {
                    peripheral.discoverCharacteristics(nil, forService: thisService)
                }
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
            let thisCharacteristic = charateristic as CBCharacteristic
            // check for data characteristic
            if thisCharacteristic.UUID == kCharacteristicUUID {
                // Enable Sensor Notification
                peripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            }
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        print("Connected")
        
        if characteristic.UUID == kCharacteristicUUID {
            
            let dataBytes = characteristic.value
            let dataLength = dataBytes!.length
            var dataArray = [Int16](count: dataLength, repeatedValue: 0)
            dataBytes!.getBytes(&dataArray, length: dataLength * sizeof(Int16))
            
            // Element 1 of the array will be ambient temperature raw value
            let ambientTemperature = Double(dataArray[1])/128
            
            // Display on the temp label
            print(NSString(format: "%.2f", ambientTemperature))
        }
    }
}