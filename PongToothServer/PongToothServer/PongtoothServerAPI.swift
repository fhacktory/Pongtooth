//
//  PongtoothServerAPI.swift
//  PongToothServer
//
//  Created by Nicolas Lourenco on 12/03/16.
//  Copyright © 2016 photograve. All rights reserved.
//

import Foundation
import CoreBluetooth

class PongToothServerAPI: NSObject, CBPeripheralManagerDelegate, CBCentralManagerDelegate {
    
    var peripheralManager: CBPeripheralManager?
    var centerManager: CBCentralManager?
    var discoveredPeripheral: [String: CBPeripheral]?
    var data: NSMutableData?
    var customCharacteristic: CBMutableCharacteristic?
    var customService: CBMutableService?
    
    struct PongToothServerAPIConstants{
        static let kServiceUUID : String = "312700E2-E798-4D5C-8DCF-49908332DF9F"
        static let kCharacteristicUUID : String = "FFA28CDE-6525-4489-801C-1C060CAC9767"
    }
    
    
    static let sharedInstance = PongToothServerAPI()
    
    override init ()
    {
        super.init()

        debugPrint("init")

//        self.centerManager = CBCentralManager.init(delegate: self, queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        self.discoveredPeripheral = [String: CBPeripheral]()
        self.data = NSMutableData()
    }
    
    func addManager()
    {
        self.peripheralManager = CBPeripheralManager.init(delegate: self, queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager)
    {
        debugPrint("peripheralManagerDidUpdateState")
        
        switch peripheral.state
        {
            case .PoweredOn:
                print("peripheral poweredOn")
                self.setupService()
                break;
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
    

    /*Central Manager*/
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state
        {
        case .PoweredOn:
            print("central poweredOn")
            central.scanForPeripheralsWithServices(nil, options:nil)
            break
        default:
            print(central.state)
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        if Float(RSSI) >= -45
        {
            central.stopScan()
            central.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Fail: %@", error)
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Connected: %@", peripheral)
//        peripheral.delegate = self
//        peripheral.discoverServices(nil)
    }
    
}