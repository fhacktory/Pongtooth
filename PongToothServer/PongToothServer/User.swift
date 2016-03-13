//
//  User.swift
//  PongToothServer
//
//  Created by Gabriel Bremond on 13/03/16.
//  Copyright © 2016 photograve. All rights reserved.
//

import Cocoa

enum UserPostion: String
{
    case left
    case right
    case top
    case bottom
}

class User : NSObject
{
    private(set) var position:UserPostion
    
    private(set) var identifier:String
    
    var score:Int = 100 {
        didSet
        {
            if score >= 0 || score <= 200
            {
                self.paddleNode?.setValue(score)
            }
        }
    }
    
    weak var edgeNode: EdgeNode?
    
    weak var paddleNode: PaddleNode?
    
    required init(userID:String, position:UserPostion)
    {
        self.position = position
        self.identifier = userID
        
        super.init()
    }
    
    func changePosition(position: CGPoint)
    {
        if self.position == UserPostion.left || self.position == UserPostion.right
        {
            paddleNode!.position.y = position.y
        }
        else
        {
            paddleNode!.position.x = position.x
        }
    }
}
