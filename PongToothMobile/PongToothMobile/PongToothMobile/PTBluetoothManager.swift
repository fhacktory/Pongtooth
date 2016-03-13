//
//  PTBluetoothManager.swift
//  PongToothMobile
//
//  Created by Emmanuel Furnon on 12/03/2016.
//  Copyright © 2016 Emmanuel Furnon. All rights reserved.
//

import Foundation
import CoreBluetooth

class PTBluetoothManager  {
    // Bluetooth manager
    var centralManager : CBCentralManager!
    var handler : PTBluetoothHandler!
    
    init () {
        self.handler = PTBluetoothHandler()
        self.centralManager = CBCentralManager(delegate:self.handler, queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
    }
}