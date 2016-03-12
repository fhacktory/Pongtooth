//
//  PongtoothServerAPI.swift
//  PongToothServer
//
//  Created by Nicolas Lourenco on 12/03/16.
//  Copyright © 2016 photograve. All rights reserved.
//

import Foundation
import CoreBluetooth

class PongToothServerAPI: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager: CBCentralManager?
    var discoveredPeripheral: [String: CBPeripheral]?
    var data: NSMutableData?
    let kServiceUUID : String = "312700E2-E798-4D5C-8DCF-49908332DF9F"
    let kCharacteristicUUID : String = "FFA28CDE-6525-4489-801C-1C060CAC9767"
    
    override init () {
        super.init()
        self.centralManager = CBCentralManager.init(delegate:self, queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        self.discoveredPeripheral = [String: CBPeripheral]()
        self.data = NSMutableData()
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager){
        
        switch central.state{
        case .PoweredOn:
            print("poweredOn")
            let uuid : CBUUID = CBUUID.init(string: kServiceUUID as String)
            centralManager?.scanForPeripheralsWithServices([uuid], options: nil)
                        // Scans for any peripheral
        default:
            print(central.state)
        }
    }
   
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        self.centralManager?.connectPeripheral(peripheral, options: nil)
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {

        self.data?.length = 0
        // Sets the peripheral delegate
        peripheral.delegate = self
        // Asks the peripheral to discover the service
        let uuid : CBUUID = CBUUID.init(string: kServiceUUID as String)
        peripheral.discoverServices([uuid])
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if (error != nil)
        {
            print(error)
        }
        else
        {
            for service in peripheral.services as [CBService]!
            {
                peripheral.discoverCharacteristics(nil, forService: service)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        if (error != nil){
            print(error)
        }
        else {
            
            if service.UUID == CBUUID(string: "180D"){
                for characteristic in service.characteristics! as [CBCharacteristic]{
                    switch characteristic.UUID.UUIDString{
                        
                    case "2A37":
                        // Set notification on heart rate measurement
                        print("Found a Heart Rate Measurement Characteristic")
                        peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                        
                    case "2A38":
                        // Read body sensor location
                        print("Found a Body Sensor Location Characteristic")
                        peripheral.readValueForCharacteristic(characteristic)
                        
                    case "2A39":
                        // Write heart rate control point
                        print("Found a Heart Rate Control Point Characteristic")
                        
                        var rawArray:[UInt8] = [0x01];
                        let data = NSData(bytes: &rawArray, length: rawArray.count)
                        peripheral.writeValue(data, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithoutResponse)
                        
                    default: break
                    }
                }
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if let _ = error{
            
        }else {
            switch characteristic.UUID.UUIDString{
                //loop on perihical
            case "2A37": break
                
            default: break
            }
        }
    }

}