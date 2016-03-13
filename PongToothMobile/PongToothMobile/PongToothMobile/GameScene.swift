//
//  GameScene.swift
//  PongToothMobile
//
//  Created by Emmanuel Furnon on 12/03/2016.
//  Copyright (c) 2016 Emmanuel Furnon. All rights reserved.
//

import SpriteKit
import CoreMotion
import MultipeerConnectivity

class GameScene: SKScene {
    
    let PADEL_WIDTH : CGFloat = 150
    let PADEL_HEIGHT : CGFloat = 10
    let PADEL_Y_FROM_BOTTOM : CGFloat = 150
    
    var motionManager: CMMotionManager!
    
    var appDelegate : AppDelegate!
    var peerName : String!
    
    // UI
    var padel : SKSpriteNode!
    var statusLabel : UILabel!
    var ball = SKSpriteNode(imageNamed:"DuskBall")
    
    lazy var accelQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "accel queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    override func didMoveToView(view: SKView) {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: NSSelectorFromString("peerDidChangeStateWithNotification:"), name:"MCDidChangeStateNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:
            NSSelectorFromString("didReceiveDataWithNotification:"), name:"MCDidReceiveDataNotification", object: nil)
        
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            self.appDelegate.peerManager?.start()
        });
        
        var lastValue : CGFloat = 0;
        
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdatesToQueue(accelQueue, withHandler:{
            data, error in
            
            let currentX = self.padel.position.x
            let destX : CGFloat = currentX - CGFloat(data!.acceleration.y * 100)
            
            if (destX - self.PADEL_WIDTH / 2) >= 0 && (destX + self.PADEL_WIDTH / 2) <= self.size.width {
                self.padel.position.x = destX
            }
            
            
            var value : CGFloat = (destX / self.size.width)
            value = round(100*value)/100
            
            if  value == lastValue {
                return
            }
            
            lastValue = value
            let toSend = String(value)
            self.appDelegate.peerManager?.sendData(toSend.dataUsingEncoding(NSUTF8StringEncoding))
        })
        
        // Set up status label
        statusLabel = UILabel()
        statusLabel.textAlignment = NSTextAlignment.Center
        statusLabel.text = "Loading..."
        statusLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        statusLabel.sizeToFit()
        statusLabel.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width, height: self.statusLabel.bounds.height)
        
        padel = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(PADEL_WIDTH, PADEL_HEIGHT))
        padel.position = CGPointMake(self.size.height / 2, PADEL_Y_FROM_BOTTOM)
        
        view.addSubview(statusLabel)
        
        self.addChild(ball)
        self.addChild(padel)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in touches {
            ball.position = touch.locationInNode(self)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func peerDidChangeStateWithNotification(notification: NSNotification) {
        let peerID = notification.userInfo!["peerID"] as! MCPeerID
        let peerDisplayName = peerID.displayName
        let stateRawValue = notification.userInfo!["state"]
        let state : MCSessionState = MCSessionState(rawValue: stateRawValue!.integerValue)!
        
        if state != MCSessionState.Connecting {
            if (state == MCSessionState.Connected) {
                peerName = peerDisplayName
            }
            else if (state == MCSessionState.NotConnected){
                peerName = nil;
            }
        }
    }
    
    func didReceiveDataWithNotification(notification: NSNotification) {
        let receivedData : NSData = notification.userInfo!["data"] as! NSData
        let receivedText : NSString = NSString(data: receivedData, encoding: NSUTF8StringEncoding)!
    
        print(receivedText)
    }
}
