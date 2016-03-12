//
//  BallNode.swift
//  PongToothServer
//
//  Created by Gabriel Bremond on 12/03/16.
//  Copyright © 2016 photograve. All rights reserved.
//

import Cocoa
import SpriteKit

class BallNode: SKSpriteNode
{
    override init(texture: SKTexture?, color: NSColor, size: CGSize)
    {
        super.init(texture: texture, color: SKColor.whiteColor(), size: texture!.size())
        
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
        name = "Ball";
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width/2)
        self.physicsBody?.categoryBitMask = NodeCategory.ball.rawValue
        self.physicsBody?.contactTestBitMask = NodeCategory.edge.rawValue | NodeCategory.ball.rawValue
        self.physicsBody?.allowsRotation = true
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.linearDamping = 0.0
        self.physicsBody?.friction = 0.0
        self.physicsBody?.mass = 0.0
    }
}
