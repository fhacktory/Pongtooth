//
//  PaddleNode.swift
//  PongToothServer
//
//  Created by Gabriel Bremond on 12/03/16.
//  Copyright © 2016 photograve. All rights reserved.
//

import Cocoa
import SpriteKit

class PaddleNode: SKSpriteNode
{
    var myLabel: SKLabelNode! = nil
    
    override init(texture: SKTexture?, color: NSColor, size: CGSize)
    {
        super.init(texture: texture, color: color, size: size)
        
        self.setUp()
    }
    
    init(texture: SKTexture?)
    {
        super.init(texture: texture, color: SKColor.clearColor(), size: texture!.size())
        
        self.setUp()
    }
    
    required init(coder: NSCoder)
    {
        super.init(coder: coder)!
        
        self.setUp()
    }
    
    func setUp()
    {
        name = "Paddle";
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.categoryBitMask = NodeCategory.paddle.rawValue
        self.physicsBody?.contactTestBitMask = NodeCategory.all.rawValue
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.pinned = false
        self.physicsBody?.linearDamping = 0.0
        self.physicsBody?.dynamic = false
        self.physicsBody?.friction = 0.0
        self.physicsBody?.mass = 0.0
        
        
        myLabel = SKLabelNode(fontNamed:"Arial")
        myLabel.text = "100"
        myLabel.fontSize = 26
        myLabel.fontColor = NSColor.redColor()
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        self.addChild(myLabel)

    }
    
    func setValue(val: Int)
    {
        myLabel.text = String(val)
    }
}
