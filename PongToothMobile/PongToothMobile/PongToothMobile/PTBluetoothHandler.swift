//
//  PTBluetoothHandler.swift
//  PongToothMobile
//
//  Created by Emmanuel Furnon on 12/03/2016.
//  Copyright © 2016 Emmanuel Furnon. All rights reserved.
//

import Foundation
import CoreBluetooth

class PTBluetoothHandler : NSObject, CBCentralManagerDelegate
{
    let kServiceUUID : String = "312700E2-E798-4D5C-8DCF-49908332DF9F"
    let kCharacteristicUUID : String = "FFA28CDE-6525-4489-801C-1C060CAC9767"
    
    override init() {
        super.init()
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager)
    {
        switch (central.state)
        {
            case .PoweredOn :
                print("great")
                central.scanForPeripheralsWithServices(nil, options: nil)
                break
            default :
                print("fail")
                break
        }
    }
    
    // Check out the discovered peripherals
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString
        
        print("Name : ")
        print(nameOfDeviceFound)
        print(peripheral.name)
        
        if (nameOfDeviceFound == "Sensor Tag") {
            // Stop scanning
            central.stopScan()
            central.connectPeripheral(peripheral, options: nil)
        }
    }
}