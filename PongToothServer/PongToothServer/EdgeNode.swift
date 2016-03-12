//
//  EdgeNode.swift
//  PongToothServer
//
//  Created by Gabriel Bremond on 12/03/16.
//  Copyright © 2016 photograve. All rights reserved.
//

import Cocoa
import SpriteKit

class EdgeNode: SKSpriteNode
{
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
        name = "Edge";
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.categoryBitMask = NodeCategory.edge.rawValue
        self.physicsBody?.collisionBitMask = NodeCategory.ball.rawValue
        self.physicsBody?.contactTestBitMask = NodeCategory.ball.rawValue
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.pinned = true
        self.physicsBody?.linearDamping = 0.0
        self.physicsBody?.dynamic = false
        self.physicsBody?.friction = 0.0
        self.physicsBody?.mass = 0.0
    }
}
