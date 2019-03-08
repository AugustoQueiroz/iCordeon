//
//  BoxService.swift
//  iCordeon
//
//  Created by Augusto Queiroz on 20/02/19.
//  Copyright © 2019 Augusto Queiroz. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import CoreMotion

enum BoxSide {
    case right, left, undefined
}

class BoxService: NSObject {
    private var side = BoxSide.undefined
    var delegate: BoxServiceDelegate?
    
    // MARK:- MultipeerConnectivity Attributes
    private let peerId = MCPeerID(displayName: UIDevice.current.name)
    
    private var advertiseType = "sound-box"
    private var serviceAdvertiser: MCNearbyServiceAdvertiser
    
    private var browseType = "sound-box"
    private var serviceBrowser: MCNearbyServiceBrowser
    
    lazy var session: MCSession = {
        let session = MCSession(peer: self.peerId, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        return session
    }()
    
    private var invitationHandler: ((Bool, MCSession?) -> Void)?
    
    // MARK:- CoreMotion Attributes
    private let motion = CMMotionManager()
    private var accelerometerTimer: Timer?
    
    private var lastAccelerometer: [Double]?
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: self.peerId, discoveryInfo: nil, serviceType: self.advertiseType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: self.peerId, serviceType: self.browseType)
        
        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceBrowser.stopBrowsingForPeers()
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.session.disconnect()
    }
    
    func acceptPairingWith(peerId: MCPeerID, as side: BoxSide) {
        if side == .right {
            self.serviceBrowser.invitePeer(peerId, to: self.session, withContext: nil, timeout: 50)
        } else {
            if let invitationHandler = self.invitationHandler {
                invitationHandler(true, self.session)
            }
        }
        self.takePosition(side)
    }
    
    func takePosition(_ position: BoxSide) {
        // Make the iPhone take one of the sides of the accordion and start behaving as such
        // Right browses, and left advertises
        if self.side == .left {
            if position == .left {
                // Do nothing
            } else if position == .right {
                self.serviceAdvertiser.stopAdvertisingPeer()
                self.serviceBrowser.stopBrowsingForPeers()
                
                self.browseType = "left-box"
                self.serviceBrowser = MCNearbyServiceBrowser(peer: self.peerId, serviceType: self.browseType)
                
                self.serviceBrowser.startBrowsingForPeers()
            } else {
                self.serviceAdvertiser.stopAdvertisingPeer()
                self.serviceBrowser.stopBrowsingForPeers()
                
                self.advertiseType = "sound-box"
                self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: self.peerId, discoveryInfo: nil, serviceType: self.advertiseType)
                
                self.serviceAdvertiser.startAdvertisingPeer()
                self.serviceBrowser.startBrowsingForPeers()
            }
        } else if self.side == .right {
            if position == .left {
                self.serviceAdvertiser.stopAdvertisingPeer()
                self.serviceBrowser.stopBrowsingForPeers()
                
                self.advertiseType = "left-box"
                self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: self.peerId, discoveryInfo: nil, serviceType: self.advertiseType)
                
                self.serviceAdvertiser.startAdvertisingPeer()
            } else if position == .right {
                // Do nothing
            } else {
                self.serviceAdvertiser.stopAdvertisingPeer()
                self.serviceBrowser.stopBrowsingForPeers()
                
                self.browseType = "sound-box"
                self.serviceBrowser = MCNearbyServiceBrowser(peer: self.peerId, serviceType: self.browseType)
                
                self.serviceAdvertiser.startAdvertisingPeer()
                self.serviceBrowser.startBrowsingForPeers()
            }
        } else {
            if position == .left {
                self.serviceAdvertiser.stopAdvertisingPeer()
                self.serviceBrowser.stopBrowsingForPeers()
                
                self.advertiseType = "left-box"
                self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: self.peerId, discoveryInfo: nil, serviceType: self.advertiseType)
                
                self.serviceAdvertiser.startAdvertisingPeer()
            } else if position == .right {
                self.serviceAdvertiser.stopAdvertisingPeer()
                self.serviceBrowser.stopBrowsingForPeers()
                
                self.browseType = "left-box"
                self.serviceBrowser = MCNearbyServiceBrowser(peer: self.peerId, serviceType: self.browseType)
                
                self.serviceBrowser.startBrowsingForPeers()
            } else {
                // Do nothing
            }
        }
        
        self.side = position
    }
    
    // MARK:- MultipeerConnectivity Methods
    func sendAccelerometer(_ x: Double, _ y: Double, _ z: Double) {
        if session.connectedPeers.count > 0 {
            do {
                
            }
        }
    }
    
    // MARK:- CoreMotion Methods
    func startAccelerometer() {
        print("starting accelerometer")
        if self.motion.isAccelerometerAvailable {
            print("accelerometer is available")
            self.motion.accelerometerUpdateInterval = 1.0 / 60.0  // 60 Hz
            self.motion.startAccelerometerUpdates()
            
            // Configure a timer to fetch the data.
            self.accelerometerTimer = Timer(fire: Date(), interval: (1.0/60.0),
                               repeats: true, block: { (timer) in
                                // Get the accelerometer data.
                                if let data = self.motion.accelerometerData {
                                    let x = data.acceleration.x
                                    let y = data.acceleration.y
                                    let z = data.acceleration.z
                                    
                                    let accData = "\(x) \(y) \(z)"
                                    self.lastAccelerometer = [x, y, z]

                                    // Use the accelerometer data in your app.
                                    do{
                                        try self.session.send(accData.data(using: .ascii)!, toPeers: self.session.connectedPeers, with: MCSessionSendDataMode.reliable)
                                    } catch let error {
                                        print(error)
                                    }
                                }
            })

            // Add the timer to the current run loop.
            RunLoop.main.add(self.accelerometerTimer!, forMode: RunLoop.Mode.default)
        }
    }
    
    func processAccelerometer(_ other: [Double]) {
        if let this = self.lastAccelerometer {
            var delta: [Double] = []
            
            for (this_i, other_i) in zip(this, other) {
                delta.append(this_i - other_i)
            }
            
            let magnitude = sqrt(delta[0]*delta[0] + delta[1]*delta[1] + delta[2]*delta[2])
            
            if magnitude > 0.1 {
                //print("iPhones se afastando/aproximando (\(magnitude))")
                self.delegate!.play(withIntensity: magnitude)
            } else {
                //print("iPhones relativamente parados(\(magnitude))")
                self.delegate!.stopPlaying()
            }
        }
    }
}

// MARK: - Adversiser Delegate
extension BoxService: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        if let delegate = self.delegate {
            delegate.askToAcceptPairing(with: peerID, as: .left)
            self.invitationHandler = invitationHandler
            print("peer connected")
        }
    }
}

// MARK: - Browser Delegate
extension BoxService: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID) [Inviting]")
        if let delegate = self.delegate {
            delegate.askToAcceptPairing(with: peerID, as: .right)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
}

// MARK: - Session Delegate
extension BoxService: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .connected {
            print("\(peerID) is connected")
            self.startAccelerometer()
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let string = String(bytes: data, encoding: .ascii)!
        let valuesStrings = string.split(separator: " ")
        var accelerometerValues: [Double] = []
        
        for valueString in valuesStrings {
            accelerometerValues.append(Double(valueString)!)
        }
        
        self.processAccelerometer(accelerometerValues)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Accelerometer stream was created on the other side
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
}
