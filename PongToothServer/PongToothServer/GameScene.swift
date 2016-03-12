//
//  GameScene.swift
//  PongToothServer
//
//  Created by Gabriel Bremond on 12/03/16.
//  Copyright (c) 2016 photograve. All rights reserved.
//

import SpriteKit

enum NodeCategory: UInt32
{
    case paddle = 0
    case edge   = 1
    case ball   = 2
}

extension CGVector
{
    func speed() -> CGFloat
    {
        return sqrt(dx*dx+dy*dy)
    }
    
    func angle() -> CGFloat
    {
        return atan2(dy, dx)
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var leftEdge:EdgeNode!
    var rightEdge:EdgeNode!
    var topEdge:EdgeNode!
    var bottomEdge:EdgeNode!
    
    var spriteBall:BallNode!
    
    var moveUp:Bool = false
    var moveDown:Bool = false

    var bounceUp:Bool = false
    var bounceLeft:Bool = false

    var ballVelocityX:CGFloat=0
    var ballVelocityY:CGFloat=0

    var ballVelocityModifier:CGFloat=0

    override func didMoveToView(view: SKView)
    {
        /* Setup your scene here */
        
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.linearDamping = 0.0
        self.physicsBody?.friction = 0.0
        self.physicsBody?.mass = 0.0

        let edgeWidth = CGFloat(10.0)
        
        // Left Edge.
        leftEdge = EdgeNode(color: NSColor.blackColor(), size: CGSize(width: edgeWidth, height: self.size.height))
        leftEdge.position = CGPoint(x: edgeWidth/2, y: CGRectGetMidY(self.frame))
        self.addChild(leftEdge)

        // Right Edge.
        rightEdge = EdgeNode(color: NSColor.blackColor(), size: CGSize(width: edgeWidth, height: self.size.height))
        rightEdge.position = CGPoint(x: self.frame.size.width-(edgeWidth/2), y: CGRectGetMidY(self.frame))
        self.addChild(rightEdge)
        
        // Top Edge.
        topEdge = EdgeNode(color: NSColor.blackColor(), size: CGSize(width: size.width, height: edgeWidth))
        topEdge.position = CGPoint(x: CGRectGetMidX(self.frame), y: edgeWidth/2)
        self.addChild(topEdge)
        
        // Bottom Edge.
        bottomEdge = EdgeNode(color: NSColor.blackColor(), size: CGSize(width: size.width, height: edgeWidth))
        bottomEdge.position = CGPoint(x: CGRectGetMidX(self.frame), y: self.frame.size.height-(edgeWidth/2))
        self.addChild(bottomEdge)

        spriteBall = BallNode(imageNamed:"ball")
        spriteBall.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        spriteBall.setScale(0.1)
        self.addChild(spriteBall)
    }
    
    override func didChangeSize(oldSize: CGSize)
    {
        let edgeWidth = CGFloat(10.0)
        
        // Left Edge.
        leftEdge?.position = CGPoint(x: edgeWidth/2, y: CGRectGetMidY(self.frame))
        
        // Right Edge.
        rightEdge?.position = CGPoint(x: self.frame.size.width-(edgeWidth/2), y: CGRectGetMidY(self.frame))
        
        // Top Edge.
        topEdge?.position = CGPoint(x: CGRectGetMidX(self.frame), y: edgeWidth/2)
        
        // Bottom Edge.
        bottomEdge?.position = CGPoint(x: CGRectGetMidX(self.frame), y: self.frame.size.height-(edgeWidth/2))
    }
    
    override func mouseDown(theEvent: NSEvent)
    {
        debugPrint("mouseDown")
        
        spriteBall.physicsBody?.applyImpulse(CGVectorMake(1000, 800))
        spriteBall.physicsBody?.applyForce(CGVectorMake(100, 80))
    }

    override func update(currentTime: CFTimeInterval)
    {
        let inVector = spriteBall.physicsBody!.velocity
        let outVector = CGVectorMake(inVector.dx*0.5, inVector.dy*0.5)
        spriteBall.physicsBody?.applyForce(outVector)
    }
    
    func didBeginContact(contact:SKPhysicsContact)
    {
        let paddleTouched = contact.bodyA.categoryBitMask == NodeCategory.paddle.rawValue
        let ballTouched = contact.bodyB.categoryBitMask == NodeCategory.ball.rawValue
        let edgeTouched = contact.bodyA.categoryBitMask == NodeCategory.edge.rawValue
        
        if (ballTouched && edgeTouched)
        {
            debugPrint("edgeTouched")
            
            let inVector = spriteBall.physicsBody!.velocity
            let outVector = CGVectorMake(inVector.dx*0.5, inVector.dy*0.5)
            spriteBall.physicsBody?.applyImpulse(outVector)
        }
       
        if (ballTouched && paddleTouched)
        {
            // Apply some force.
            if(self.moveUp)
            {
                self.bounceUp = true
            }
            else if (self.moveDown)
            {
                self.bounceUp = false
            }
            
            self.bounceLeft = !self.bounceLeft
            self.ballVelocityModifier = CGFloat( tanf( Float(self.randomAngle()) ) );
        }
    }
    
// MARK: Special functions.
    
    func randomAngle() -> CGFloat
    {
        let uintValue = self.randomNumberFrom(25, to: 35)
        return CGFloat(uintValue) * CGFloat(M_PI / 180)
    }
    
    func randomNumberFrom(low:UInt32, to:UInt32) -> UInt32
    {
        return low +  ( arc4random() % (to - low + 1) )
    }
    
    func randomPercentageFrom(low:UInt32, to:UInt32) -> CGFloat
    {
        let uintValue = self.randomNumberFrom(low, to: to)
        return CGFloat(uintValue) / 100.0
    }

}
