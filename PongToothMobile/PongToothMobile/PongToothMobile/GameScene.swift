//
//  GameScene.swift
//  PongToothMobile
//
//  Created by Emmanuel Furnon on 12/03/2016.
//  Copyright (c) 2016 Emmanuel Furnon. All rights reserved.
//

import SpriteKit
import CoreBluetooth

class GameScene: SKScene, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // IR Temp UUIDs
    let IRTemperatureServiceUUID = CBUUID(string: "F000AA00-0451-4000-B000-000000000000")
    let IRTemperatureDataUUID   = CBUUID(string: "F000AA01-0451-4000-B000-000000000000")
    let IRTemperatureConfigUUID = CBUUID(string: "F000AA02-0451-4000-B000-000000000000")
    
    // Bluetooth manager
    var centralManager : CBCentralManager!
    var sensorTagPeripheral : CBPeripheral!
    
    // UI
    var statusLabel : UILabel!
    var ball = SKSpriteNode(imageNamed:"DuskBall")
    
    override func didMoveToView(view: SKView) {
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Set up status label
        statusLabel = UILabel()
        statusLabel.textAlignment = NSTextAlignment.Center
        statusLabel.text = "Loading..."
        statusLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        statusLabel.sizeToFit()
        statusLabel.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width, height: self.statusLabel.bounds.height)
        view.addSubview(statusLabel)
        
        self.addChild(ball)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
        
            ball.position = location
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    // Bluetooth
    
    
    
    // Discover services of the peripheral
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        self.statusLabel.text = "Discovering peripheral services"
        peripheral.discoverServices(nil)
    }
    
    // Check if the service discovered is a valid IR Temperature Service
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        self.statusLabel.text = "Looking at peripheral services"
        for service in peripheral.services! {
            let thisService = service as CBService
            if service.UUID == IRTemperatureServiceUUID {
                // Discover characteristics of IR Temperature Service
                peripheral.discoverCharacteristics(nil, forService: thisService)
            }
            // Uncomment to print list of UUIDs
            //println(thisService.UUID)
        }
    }
    
    // Enable notification and sensor for each characteristic of valid service
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        // update status label
        self.statusLabel.text = "Enabling sensors"
        
        // 0x01 data byte to enable sensor
        var enableValue = 1
        let enablyBytes = NSData(bytes: &enableValue, length: sizeof(UInt8))
        
        // check the uuid of each characteristic to find config and data characteristics
        for charateristic in service.characteristics! {
            let thisCharacteristic = charateristic as CBCharacteristic
            // check for data characteristic
            if thisCharacteristic.UUID == IRTemperatureDataUUID {
                // Enable Sensor Notification
                self.sensorTagPeripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            }
            // check for config characteristic
            if thisCharacteristic.UUID == IRTemperatureConfigUUID {
                // Enable Sensor
                self.sensorTagPeripheral.writeValue(enablyBytes, forCharacteristic: thisCharacteristic, type: CBCharacteristicWriteType.WithResponse)
            }
        }
        
    }
}
