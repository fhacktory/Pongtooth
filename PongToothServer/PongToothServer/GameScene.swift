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
    case none   = 0
    case all    = 0xffffffff
    case paddle = 1
    case edge   = 2
    case ball   = 3
}

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var leftEdge:EdgeNode!
    var rightEdge:EdgeNode!
    var topEdge:EdgeNode!
    var bottomEdge:EdgeNode!
    
    var spriteBalls: [BallNode] = []
    
    var paddles: [PaddleNode] = []
    var soundEffectAction:SKAction = SKAction.playSoundFileNamed("beep.wav", waitForCompletion: false)
    var soundEffectMiss:SKAction = SKAction.playSoundFileNamed("bop.wav", waitForCompletion: false)
    
    var users: [User] = []

// MARK:
// MARK: Overrides
    
    override func didMoveToView(view: SKView)
    {
        /* Setup your scene here */
        
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.linearDamping = 0.0
        self.physicsBody?.friction = 0.0
        self.physicsBody?.mass = 0.0
        
        self.addChild(createEdge(UserPostion.left, width: CGFloat(1)))
        self.addChild(createEdge(UserPostion.right, width: CGFloat(1)))
        self.addChild(createEdge(UserPostion.bottom, width: CGFloat(1)))
        self.addChild(createEdge(UserPostion.top, width: CGFloat(1)))
    }
    
    override func mouseDown(theEvent: NSEvent)
    {
        addUser("1")

        let position = theEvent.locationInNode(self)

        let spriteBall = BallNode(imageNamed:"ball")
        spriteBall.position = position
        spriteBall.setScale(0.1)

        self.addChild(spriteBall)
        spriteBalls.append(spriteBall)
        
        spriteBall.physicsBody?.applyImpulse(CGVectorMake(1000, 800))
        spriteBall.physicsBody?.applyForce(CGVectorMake(100, 80))
    }
    
    override func mouseMoved(theEvent: NSEvent)
    {
        let position = theEvent.locationInNode(self)
        
        for user in users
        {
            if user.position == UserPostion.left || user.position == UserPostion.right
            {
                user.paddleNode!.position.y = position.y
            }
            else
            {
                user.paddleNode!.position.x = position.x
            }
        }
    }

    override func update(currentTime: CFTimeInterval)
    {
        // Add dynamic to balls
        for ball in spriteBalls
        {
            let inVector = ball.physicsBody!.velocity
            let outVector = CGVectorMake(inVector.dx*0.5, inVector.dy*0.5)
            ball.physicsBody?.applyForce(outVector)
        }
    }

    
// MARK:
// MARK: SKPhysicsContactDelegate

    func didBeginContact(contact:SKPhysicsContact)
    {
        let paddleTouched = contact.bodyA.categoryBitMask == NodeCategory.paddle.rawValue
        let ballTouched = contact.bodyB.categoryBitMask == NodeCategory.ball.rawValue
        let edgeTouched = contact.bodyA.categoryBitMask == NodeCategory.edge.rawValue
        
        if (ballTouched && edgeTouched)
        {
            let inVector = contact.bodyB.node!.physicsBody!.velocity
            let outVector = CGVectorMake(inVector.dx*0.5, inVector.dy*0.5)
            contact.bodyB.node!.physicsBody?.applyImpulse(outVector)
            
            self.runAction(self.soundEffectMiss)
        }
        else if (ballTouched && paddleTouched)
        {
            let inVector = contact.bodyB.node!.physicsBody!.velocity
            let outVector = CGVectorMake(inVector.dx*2, inVector.dy*2)
            contact.bodyB.node!.physicsBody?.applyImpulse(outVector)
            contact.bodyB.node!.physicsBody?.applyForce(outVector)
     
            self.runAction(self.soundEffectAction)
        }
        else
        {
            debugPrint("otherTouched")
        }
    }
    
    
// MARK:
// MARK: Customs
    
    func addUser(userID: String) -> Bool
    {
        if self.users.count >= 4
        {
            return false
        }
        
        let positions = [UserPostion.left, UserPostion.right, UserPostion.bottom, UserPostion.top]
        
        let user = User(userID: "", position: positions[users.count])
        addEdge(user)
        addPaddle(user)
        users.append(user)
        
        return true
    }
    
    func addEdge(user: User)
    {
        let edge = createEdge(user.position, width: CGFloat(10))
        self.addChild(edge)
        user.edgeNode = edge
    }
    
    func createEdge(position: UserPostion, width: CGFloat) -> EdgeNode
    {
        let edge: EdgeNode!

        switch position
        {
            // Left Edge.
        case UserPostion.left:
            edge = EdgeNode(color: NSColor.blackColor(), size: CGSize(width: width, height: self.size.height))
            edge.position = CGPoint(x: width/2, y: CGRectGetMidY(self.frame))
            break
            
            // Right Edge.
        case UserPostion.right:
            edge = EdgeNode(color: NSColor.blackColor(), size: CGSize(width: width, height: self.size.height))
            edge.position = CGPoint(x: self.frame.size.width-(width/2), y: CGRectGetMidY(self.frame))
            break
            
            // Top Edge.
        case UserPostion.top:
            edge = EdgeNode(color: NSColor.blackColor(), size: CGSize(width: size.width, height: width))
            edge.position = CGPoint(x: CGRectGetMidX(self.frame), y: width/2)
            break
            
            // Bottom Edge.
        case UserPostion.bottom:
            edge = EdgeNode(color: NSColor.blackColor(), size: CGSize(width: size.width, height: width))
            edge.position = CGPoint(x: CGRectGetMidX(self.frame), y: self.frame.size.height-(width/2))
            break
        }
        
        return edge
    }
    
    func addPaddle(user: User)
    {
        var paddle: PaddleNode!
  
        switch user.position
        {
            // Left Edge.
        case UserPostion.left:
            paddle = PaddleNode(color: NSColor.darkGrayColor(), size: CGSize(width: user.edgeNode!.size.width, height: user.edgeNode!.size.height/5))
            paddle?.position = CGPoint(x: user.edgeNode!.position.x + 30, y: user.edgeNode!.position.y)
            break
            
            // Right Edge.
        case UserPostion.right:
            paddle = PaddleNode(color: NSColor.orangeColor(), size: CGSize(width: user.edgeNode!.size.width, height: user.edgeNode!.size.height/5))
            paddle?.position = CGPoint(x: user.edgeNode!.position.x - 30, y: user.edgeNode!.position.y)
            break
            
            // Top Edge.
        case UserPostion.top:
            paddle = PaddleNode(color: NSColor.blueColor(), size: CGSize(width: user.edgeNode!.size.width/5, height: user.edgeNode!.size.height))
            paddle?.position = CGPoint(x: user.edgeNode!.position.x, y: user.edgeNode!.position.y + 30)
            break
            
            // Bottom Edge.
        case UserPostion.bottom:
            paddle = PaddleNode(color: NSColor.greenColor(), size: CGSize(width: user.edgeNode!.size.width/5, height: user.edgeNode!.size.height))
            paddle?.position = CGPoint(x: user.edgeNode!.position.x, y: user.edgeNode!.position.y - 30)
            break
        }

        self.addChild(paddle!)
        user.paddleNode = paddle
    }
}
