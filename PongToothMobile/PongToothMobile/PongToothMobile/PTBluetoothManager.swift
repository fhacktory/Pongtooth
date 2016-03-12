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
        self.handler = PTBBluetoothHandler()
    }
}