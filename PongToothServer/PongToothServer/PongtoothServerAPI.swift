//
//  PongtoothServerAPI.swift
//  PongToothServer
//
//  Created by Nicolas Lourenco on 12/03/16.
//  Copyright © 2016 photograve. All rights reserved.
//

import Foundation
import CoreBluetooth

class PongToothServerAPI: NSObject, CBPeripheralManagerDelegate {
    
    var peripheralManager: CBPeripheralManager?
    var discoveredPeripheral: [String: CBPeripheral]?
    var data: NSMutableData?
    var customCharacteristic: CBMutableCharacteristic?
    var customService: CBMutableService?
    
    struct PongToothServerAPIConstants{
        static let kServiceUUID : String = "312700E2-E798-4D5C-8DCF-49908332DF9F"
        static let kCharacteristicUUID : String = "FFA28CDE-6525-4489-801C-1C060CAC9767"
    }
    
    
    static let sharedInstance = PongToothServerAPI()
    
    override init () {
        super.init()
        self.peripheralManager = CBPeripheralManager.init(delegate: self, queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        self.discoveredPeripheral = [String: CBPeripheral]()
        self.data = NSMutableData()
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        switch peripheral.state{
        case .PoweredOn:
            print("poweredOn")
            // Scans for any peripheral
            self.setupService()
        default:
            print(peripheral.state)
        }
    }
    
    func setupService()
    {

        // Creates the characteristic UUID
        let characteristicUUID : CBUUID = CBUUID.init(string: PongToothServerAPIConstants.kCharacteristicUUID as String)
    
        // Creates the characteristic
        customCharacteristic = CBMutableCharacteristic.init(type: characteristicUUID, properties: CBCharacteristicProperties.Notify, value: nil, permissions: CBAttributePermissions.Readable)
    
        // Creates the service UUID
        let serviceUUID: CBUUID = CBUUID.init(string: PongToothServerAPIConstants.kServiceUUID)
    
        // Creates the service and adds the characteristic to it
        self.customService = CBMutableService.init(type: serviceUUID, primary: true)
        
        // Sets the characteristics for this service
        self.customService!.characteristics = [customCharacteristic!]
    
        // Publishes the service
        self.peripheralManager?.addService(self.customService!)
        print("addService")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        print("didAddService")
        if error == nil {
            let serviceUUID: CBUUID = CBUUID.init(string: PongToothServerAPIConstants.kServiceUUID)
            self.peripheralManager?.startAdvertising([CBAdvertisementDataLocalNameKey:"ICServer",
                CBAdvertisementDataServiceUUIDsKey:[serviceUUID]])
        }
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