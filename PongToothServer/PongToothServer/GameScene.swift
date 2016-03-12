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
    
    var paddles: [PaddleNode]!
    var soundEffectAction:SKAction = SKAction.playSoundFileNamed("beep.wav", waitForCompletion: false)
    var soundEffectMiss:SKAction = SKAction.playSoundFileNamed("bop.wav", waitForCompletion: false)
    
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
        
        paddles = []

        let edgeWidth = CGFloat(10.0)
        
        // Left Edge.
        leftEdge = EdgeNode(color: NSColor.blackColor(), size: CGSize(width: edgeWidth, height: self.size.height))
        leftEdge.position = CGPoint(x: edgeWidth/2, y: CGRectGetMidY(self.frame))
        self.addChild(leftEdge)
        
        addPaddle(leftEdge)

        // Right Edge.
        rightEdge = EdgeNode(color: NSColor.blackColor(), size: CGSize(width: edgeWidth, height: self.size.height))
        rightEdge.position = CGPoint(x: self.frame.size.width-(edgeWidth/2), y: CGRectGetMidY(self.frame))
        self.addChild(rightEdge)
        
        addPaddle(rightEdge)
       
        // Top Edge.
        topEdge = EdgeNode(color: NSColor.blackColor(), size: CGSize(width: size.width, height: edgeWidth))
        topEdge.position = CGPoint(x: CGRectGetMidX(self.frame), y: edgeWidth/2)
        self.addChild(topEdge)
        
        addPaddle(topEdge)
       
        // Bottom Edge.
        bottomEdge = EdgeNode(color: NSColor.blackColor(), size: CGSize(width: size.width, height: edgeWidth))
        bottomEdge.position = CGPoint(x: CGRectGetMidX(self.frame), y: self.frame.size.height-(edgeWidth/2))
        self.addChild(bottomEdge)
        
        addPaddle(bottomEdge)

        spriteBall = BallNode(imageNamed:"ball")
        spriteBall.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        spriteBall.setScale(0.1)
        self.addChild(spriteBall)
        
        PongToothServerAPI.sharedInstance.addManager()
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
    
    func addPaddle(edge: EdgeNode)
    {
        var paddle: PaddleNode?
        
        if edge == leftEdge
        {
            paddle = PaddleNode(color: NSColor.darkGrayColor(), size: CGSize(width: edge.size.width, height: edge.size.height/5))
            paddle?.position = CGPoint(x: edge.position.x + 30, y: edge.position.y)
            paddle?.node = leftEdge
        }
        else if edge == rightEdge
        {
            paddle = PaddleNode(color: NSColor.orangeColor(), size: CGSize(width: edge.size.width, height: edge.size.height/5))
            paddle?.position = CGPoint(x: edge.position.x - 30, y: edge.position.y)
            paddle?.node = rightEdge
        }
        else if edge == topEdge
        {
            paddle = PaddleNode(color: NSColor.blueColor(), size: CGSize(width: edge.size.width/5, height: edge.size.height))
            paddle?.position = CGPoint(x: edge.position.x, y: edge.position.y + 30)
            paddle?.node = topEdge
        }
        else if edge == bottomEdge
        {
            paddle = PaddleNode(color: NSColor.greenColor(), size: CGSize(width: edge.size.width/5, height: edge.size.height))
            paddle?.position = CGPoint(x: edge.position.x, y: edge.position.y - 30)
            paddle?.node = bottomEdge
        }
     
        if paddle != nil
        {
            self.addChild(paddle!)
            paddles.append(paddle!)
        }
    }
    
    override func mouseDown(theEvent: NSEvent)
    {
        debugPrint("mouseDown")
        
        spriteBall.physicsBody?.applyImpulse(CGVectorMake(1000, 800))
        spriteBall.physicsBody?.applyForce(CGVectorMake(100, 80))
    }
    
    override func mouseMoved(theEvent: NSEvent)
    {
        let position = theEvent.locationInNode(self)
        
        for paddle in paddles
        {
            if paddle.node == leftEdge || paddle.node == rightEdge
            {
                paddle.position.y = position.y
            }
            else
            {
                paddle.position.x = position.x
            }
        }
    }

    override func update(currentTime: CFTimeInterval)
    {
        let inVector = spriteBall.physicsBody!.velocity
        let outVector = CGVectorMake(inVector.dx*0.5, inVector.dy*0.5)
        spriteBall.physicsBody?.applyForce(outVector)
    }
    
    func didBeginContact(contact:SKPhysicsContact)
    {
        let paddleTouched = contact.bodyA.categoryBitMask == NodeCategory.ball.rawValue
        let ballTouched = contact.bodyB.categoryBitMask == NodeCategory.ball.rawValue
        let edgeTouched = contact.bodyA.categoryBitMask == NodeCategory.edge.rawValue
        
        if (ballTouched && edgeTouched)
        {
            debugPrint("edgeTouched")
            
            let inVector = spriteBall.physicsBody!.velocity
            let outVector = CGVectorMake(inVector.dx*0.5, inVector.dy*0.5)
            spriteBall.physicsBody?.applyImpulse(outVector)
            
            self.runAction(self.soundEffectMiss)
        }
        
        if (ballTouched && paddleTouched)
        {
            debugPrint("paddleTouched")
            
            let inVector = spriteBall.physicsBody!.velocity
            let outVector = CGVectorMake(inVector.dx*2, inVector.dy*2)
            spriteBall.physicsBody?.applyImpulse(outVector)
            spriteBall.physicsBody?.applyForce(outVector)
     
            self.runAction(self.soundEffectAction)
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
