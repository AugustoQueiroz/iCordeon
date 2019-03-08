//
//  BoxServiceDelegate.swift
//  iCordeon
//
//  Created by Augusto Queiroz on 20/02/19.
//  Copyright © 2019 Augusto Queiroz. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol BoxServiceDelegate {
    func askToAcceptPairing(with: MCPeerID, as position: BoxSide)
    
    func play(withIntensity intensity: Double)
    func stopPlaying()
}
