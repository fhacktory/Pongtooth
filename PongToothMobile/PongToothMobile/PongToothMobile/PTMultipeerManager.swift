//
//  PTMultipeerManager.swift
//  PongToothMobile
//
//  Created by Emmanuel Furnon on 13/03/2016.
//  Copyright © 2016 Emmanuel Furnon. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class PTMultipeerManager : NSObject, MCSessionDelegate {
    var peerID : MCPeerID!
    var session : MCSession!
    var advertiser : MCAdvertiserAssistant!
    
    override init () {
        super.init()
    }
    
    func setupPeerAndSession() {
        self.peerID = MCPeerID(displayName: "pongtooth");
    
        self.session = MCSession(peer: self.peerID);
        self.session.delegate = self;
    }
    
    func advertiseSelf(shouldAdvertise: Bool) {
        if (shouldAdvertise) {
            advertiser = MCAdvertiserAssistant(serviceType: "pongtooth", discoveryInfo: nil, session: self.session);
            advertiser.start();
        }
        else{
            advertiser.stop();
            advertiser = nil;
        }
    }
    
    func session(session: MCSession, peer: MCPeerID, didChangeState state: MCSessionState) {
        let dict = ["peerID": peerID, "state" : state.rawValue]
        
        NSNotificationCenter.defaultCenter().postNotificationName("MCDidChangeStateNotification", object: nil, userInfo: dict)
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID){
        let dict = ["data": data,
            "peerID": peerID]
        
        NSNotificationCenter.defaultCenter().postNotificationName("MCDidReceiveDataNotification", object: nil, userInfo: dict);
    }
    
    
    func session(session: MCSession, didReceiveStream: NSInputStream, withName: String, fromPeer: MCPeerID) {
    
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName: String, fromPeer: MCPeerID, withProgress: NSProgress) {
        
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName: String, fromPeer: MCPeerID, atURL: NSURL, withError: NSError?) {
        
    }
    
    func session(session: MCSession, didReceiveCertificate: [AnyObject]?, fromPeer: MCPeerID, certificateHandler: (Bool) -> Void) {
        
    }
}
