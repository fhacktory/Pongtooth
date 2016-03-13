//
//  MultiPeer.swift
//  Around
//
//  Created by Gabriel Bremond on 29/12/14.
//  Copyright (c) 2014 photograve. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MultiPeer : NSObject , MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate
{
    var service : MCNearbyServiceAdvertiser!
    var browser : MCNearbyServiceBrowser!
    var session : MCSession!
    var connectedPeers : NSMutableArray
    let peerID: MCPeerID = MCPeerID(displayName: "pongtooth")
    let serviceType: String = "pongtooth"
    
    override init()
    {
        self.connectedPeers = NSMutableArray()
        
        super.init()
        
        service = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        service.delegate = self
        
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser.delegate = self;
        
    }
    
    func start()
    {
        service.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }
    
    func stop()
    {
        service.stopAdvertisingPeer()
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?,
        invitationHandler: (Bool, MCSession) -> Void)
    {
        if self.session == nil  {
            self.session = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.None)
            self.session.delegate = self;
            
            invitationHandler(true, self.session)
            
            self.service.stopAdvertisingPeer()
            self.browser.stopBrowsingForPeers()
        }
        
         print(service, "didReceiveInvitationFromPeer")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if self.session == nil  {
            self.session = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.None)
            self.session.delegate = self;
            
            browser.invitePeer(self.peerID, toSession: self.session, withContext: nil, timeout: 10)
            
            self.service.stopAdvertisingPeer()
            self.browser.stopBrowsingForPeers()
        }
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        self.session = nil
        
        self.start()
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError)
    {
        print(service, "didNotStartAdvertisingPeer")
    }
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        print(state)
        
        if (state == MCSessionState.Connected) {
            print("Connected to ", peerID.displayName)
            
            self.connectedPeers.addObject(peerID)
        }
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        
    }

}