//
//  MultiPeer.swift
//  PongToothMobile
//
//  Created by Emmanuel Furnon on 13/03/2016.
//  Copyright © 2016 Emmanuel Furnon. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MultiPeer : NSObject, MCNearbyServiceBrowserDelegate, MCSessionDelegate
{
    var browser : MCNearbyServiceBrowser!
    var session : MCSession!
    var connectedPeers : NSMutableArray
    let peerID: MCPeerID = MCPeerID(displayName: "pongtooth-mobile-2")
    let serviceType: String = "pongtooth"
    
    override init()
    {
        self.connectedPeers = NSMutableArray()
        
        super.init()
        
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser.delegate = self;
    }
    
    func start()
    {
        browser.startBrowsingForPeers()
    }
    
    func stop()
    {
        browser.stopBrowsingForPeers()
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if self.session == nil  {
            self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.None)
            self.session.delegate = self
            
            browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
        }
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        self.session = nil
        
        self.start()
    }
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        print(state)
        
        if (state == MCSessionState.Connected) {
            print("Connected to ", peerID.displayName)
            
            
        }
        print(state.rawValue)
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        
        print("FinishReceivingResource ", peerID.displayName)
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        
        print("ReceiveData ", peerID.displayName)
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
        print("ReceiveStream ", peerID.displayName)
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        
        print("StartReceivingResource ", peerID.displayName)
    }
    
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void)
    {
        debugPrint(session,"didReceiveCertificate")
        
        certificateHandler(true)
    }
}