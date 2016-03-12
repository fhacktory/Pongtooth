//
//  AppDelegate.swift
//  PongToothServer
//
//  Created by Gabriel Bremond on 12/03/16.
//  Copyright (c) 2016 photograve. All rights reserved.
//


import Cocoa
import SpriteKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate
{
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    
    func applicationDidFinishLaunching(aNotification: NSNotification)
    {
        window.acceptsMouseMovedEvents = true
        window.delegate = self

        debugPrint("Window frame: ",window.frame)
        
        /* Pick a size for the scene */
        let scene = GameScene(size:self.skView!.bounds.size)
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        scene.backgroundColor = NSColor.whiteColor()
        
        self.skView!.presentScene(scene)
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        self.skView!.ignoresSiblingOrder = true
        
        self.skView!.showsFPS = true
        self.skView!.showsNodeCount = true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool
    {
        return true
    }
    
// MARK: NSWindowDelegate
    
    func windowDidResize(notification: NSNotification)
    {
        debugPrint("Window frame: ",window.frame)
        skView.scene?.size = window.frame.size
        skView.scene?.didChangeSize(CGSize())
    }
}
