//
//  MultiPeer.swift
//  Around
//
//  Created by Gabriel Bremond on 29/12/14.
//  Copyright (c) 2014 photograve. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MultiPeer : NSObject , MCNearbyServiceAdvertiserDelegate, MCSessionDelegate
{
    var service : MCNearbyServiceAdvertiser!
    var session : MCSession!
    var remote : MCSession!
    
    var connectedPeers : NSMutableArray = NSMutableArray()
    let peerID: MCPeerID = MCPeerID(displayName: "pongtoothserver")
    let serviceType: String = "pongtooth"
    
    var assistant: MCAdvertiserAssistant!
    
    override init()
    {
        super.init()
        
        service = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        service.delegate = self
//        
//        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.None)
//        self.session.delegate = self;
//
//        assistant = MCAdvertiserAssistant (serviceType: serviceType, discoveryInfo: nil, session: self.session)
    }
    
    func start()
    {
        debugPrint("start")
        
        service.startAdvertisingPeer()
//        assistant.start()
    }
    
    func stop()
    {
        debugPrint("stop")

        service.stopAdvertisingPeer()
    }
    
    
    // MARK:
    // MARK: MCNearbyServiceAdvertiserDelegate
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?,
        invitationHandler: (Bool, MCSession) -> Void)
    {
        debugPrint(advertiser, "didReceiveInvitationFromPeer")
        debugPrint(peerID, "withPeerID")

        if context != nil
        {
            let clientMessage = String(data: context!, encoding: NSUTF8StringEncoding)
            debugPrint("Message: ", clientMessage)
        }
        
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.None)
        self.session.delegate = self;
        
        invitationHandler(true, self.session)
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError)
    {
        debugPrint(advertiser, "didNotStartAdvertisingPeer")
    }
    
    // MARK:
    // MARK: MCSessionDelegate
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState)
    {
        print(state.rawValue)
        
        if (state == MCSessionState.Connecting)
        {
            session.nearbyConnectionDataForPeer(peerID, withCompletionHandler: { (data, error) -> Void in
                let string = String(data: data, encoding: NSUTF8StringEncoding)
                debugPrint("Connection data: ", string)
                
                session.connectPeer(peerID, withNearbyConnectionData:data)
            })
        }
        else if (state == MCSessionState.Connected)
        {
            print("Connected to ", peerID.displayName)
            
            self.connectedPeers.addObject(peerID)
        }
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?)
    {
        debugPrint(session,"didFinishReceivingResourceWithName")
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID)
    {
        debugPrint(session,"didReceiveData")
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID)
    {
        debugPrint(session,"didReceiveStream")
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress)
    {
        debugPrint(session,"didStartReceivingResourceWithName")
    }

    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void)
    {
        debugPrint(session,"didReceiveCertificate",certificate)
        
        certificateHandler(true)
    }
}