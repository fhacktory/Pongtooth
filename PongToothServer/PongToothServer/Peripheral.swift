//
//  Peripheral.swift
//  PongToothServer
//
//  Created by Gabriel Bremond on 13/03/16.
//  Copyright © 2016 photograve. All rights reserved.
//

import Foundation
import CoreBluetooth


class Peripheral: NSObject, CBPeripheralManagerDelegate
{
    var peripheralManager: CBPeripheralManager!
    
    var transferCharacteristic: CBMutableCharacteristic!

    override init()
    {
        super.init()        
    }
    
    func start()
    {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            debugPrint("advertise")
            self.peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961")])
        }
    }

    func sendData()
    {
        let key = "KEY"
        let didSend = self.peripheralManager.updateValue(key.dataUsingEncoding(NSUTF8StringEncoding)!, forCharacteristic: self.transferCharacteristic, onSubscribedCentrals: nil)
        
        // Did it send?
        if (didSend)
        {
            // It did, so mark it as sent
            debugPrint("Sent: KEY")
        }
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager)
    {
        // Opt out from any other state
        if peripheral.state != CBPeripheralManagerState.PoweredOn
        {
            return
        }
        
        // We're in CBPeripheralManagerStatePoweredOn state...
        debugPrint("self.peripheralManager powered on.")
        
        // ... so build our service.
        
        // Start with the CBMutableCharacteristic
        self.transferCharacteristic = CBMutableCharacteristic(type: CBUUID(string: "08590F7E-DB05-467E-8757-72F6FAEB13D4"), properties: CBCharacteristicProperties.Notify, value: nil, permissions: CBAttributePermissions.Readable)
        
        // Then the service
        let transferService = CBMutableService(type: CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961"), primary: true)
        
        // Add the characteristic to the service
        transferService.characteristics = [self.transferCharacteristic]
        
        // And add it to the peripheral manager
        self.peripheralManager.addService(transferService)
    }

    func peripheralManager(peripheral: CBPeripheralManager, willRestoreState dict: [String : AnyObject])
    {
        debugPrint("willRestoreState")
    }

    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?)
    {
        debugPrint("peripheralManagerDidStartAdvertising")
    }
 
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?)
    {
        debugPrint("didAddService")
    }

    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic)
    {
        debugPrint("didSubscribeToCharacteristic")
        
        // Send data
        sendData()
    }
 
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic)
    {
        debugPrint("didUnsubscribeFromCharacteristic")
    }

    func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest)
    {
        debugPrint("didReceiveReadRequest")
    }

    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest])
    {
        debugPrint("didReceiveWriteRequests")
    }
 
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager)
    {
        debugPrint("peripheralManagerIsReadyToUpdateSubscribers")

        // Send data
        sendData()
    }
}
