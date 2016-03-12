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
    var range: NSRange?
    
    struct PongToothServerAPIConstants{
        static let kServiceUUID : String = "312700E2-E798-4D5C-8DCF-49908332DF9F"
        static let kCharacteristicUUID : String = "FFA28CDE-6525-4489-801C-1C060CAC9767"
    }
    
    
    static let sharedInstance = PongToothServerAPI()
    
    override init ()
    {
        super.init()
        self.discoveredPeripheral = [String: CBPeripheral]()
        self.data = NSMutableData()

    }
    
    func addManager()
    {
        self.peripheralManager = CBPeripheralManager.init(delegate: self, queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        self.centerManager = CBCentralManager.init(delegate: self, queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager)
    {
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
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state
        {
        case .PoweredOn:
            print("central poweredOn")
            centerManager?.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:NSNumber(bool: true)])
            break;
        default:
            print(central.state)
        }

    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
//        [central stopScan];
//        aCperipheral = aPeripheral;
//        centra
////        [central connectPeripheral:aCperipheral options:nil];
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        self.writeData(peripheral)
    }
    
    func writeData(peripheral: CBPeripheralManager)
    {
        let infos: Dictionary = ["NAME" : "Khaos Tian","EMAIL":"khaos.tian@gmail.com"]

        do {
            if let aData: NSData = try NSJSONSerialization.dataWithJSONObject(infos, options: []) {
                self.data?.appendData(aData)
                
                while self.hasData()
                {
                    if peripheral.updateValue(self.nextData(), forCharacteristic: customCharacteristic!, onSubscribedCentrals: nil) {
                        self.readData()
                    } else {
                        return
                    }
                    let stra:String = "ENDAL"
                    let dataa :NSData = NSData.init(base64EncodedString: stra, options: [])!
                    peripheral.updateValue(dataa, forCharacteristic: customCharacteristic!, onSubscribedCentrals: nil)
                }
                
            }
        } catch let parseError {
            print(parseError)                                                          // Log the error thrown by `JSONObjectWithData`
        }
    }
    
    func readData()
    {
        if  self.data?.length > 19 {
            self.data?.subdataWithRange(range!)
        } else {
            self.data = nil;
        }
    }
    

    
    func hasData()-> Bool
    {
        if self.data?.length > 0
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func nextData() ->  NSData
    {
        var aData = NSData()
        
        if  self.data?.length > 19
        {
            let dataRest: Int = (self.data?.length)! - 20
            
            if let data = self.data?.subdataWithRange(NSRange(location: 0, length: 20))
            {
                aData = NSData(base64EncodedData: data, options: [])!
                range = NSRange(location: 20, length: dataRest)
            }
        }
        else
        {
            if let dataRest: Int = self.data?.length
            {
                range = NSRange(location: 0, length: dataRest)
                
                if let data = self.data?.subdataWithRange(range!)
                {
                    aData = NSData.init(base64EncodedData: data, options: [])!
                }
            }
        }
        
        return aData
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral)
    {
        print("jme connecte tavu")
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
            self.peripheralManager?.startAdvertising([CBAdvertisementDataLocalNameKey:"com.fhacktory.pongtooth",
                CBAdvertisementDataServiceUUIDsKey:[serviceUUID]])
        }
    }
    
    
}