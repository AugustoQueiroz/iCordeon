//
//  SoundBoxDelegat.swift
//  iCordeon
//
//  Created by Augusto Queiroz on 22/02/19.
//  Copyright © 2019 Augusto Queiroz. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol SoundBoxDelegate {
    func askToAcceptPairing(with peerId: MCPeerID, as position: BoxSide)
}
