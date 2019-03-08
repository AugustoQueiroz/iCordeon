//
//  ViewController.swift
//  iCordeon
//
//  Created by Augusto Queiroz on 20/02/19.
//  Copyright © 2019 Augusto Queiroz. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import CoreAudioKit

class ViewController: UIViewController, SoundBoxDelegate {
    // MARK: - Interface
    @IBOutlet weak var firstKey: UIButton!
    @IBOutlet weak var secondKey: UIButton!
    @IBOutlet weak var thirdKey: UIButton!
    @IBOutlet weak var fourthKey: UIButton!
    
    @IBOutlet weak var pairConfirmationButton: UIButton!
    
    // MARK: - General Attributes
    var sideDefined: Bool = false
    var side: BoxSide = .undefined
    var peerId: MCPeerID?
    
    let soundBox = SoundBox()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.pairConfirmationButton.isHidden = true
        
        self.soundBox.delegate = self
    }
    
    func askToAcceptPairing(with peerId: MCPeerID, as position: BoxSide) {
        if position == .left {
            self.pairConfirmationButton.backgroundColor = #colorLiteral(red: 0.03921568627, green: 0.7254901961, blue: 0.9019607843, alpha: 1)
        }
        self.pairConfirmationButton.isHidden = false
        
        self.side = position
        self.peerId = peerId
    }
    
    @IBAction func keyPressed(_ sender: UIButton) {
        switch sender {
        case firstKey:
            self.soundBox.addActiveNote(.C)
            
        case secondKey:
            self.soundBox.addActiveNote(.D)
            
        case thirdKey:
            self.soundBox.addActiveNote(.E)
            
        case fourthKey:
            self.soundBox.addActiveNote(.F)
            
        default:
            self.soundBox.addActiveNote(.G)
        }
        
        //self.soundBox.play(withIntensity: 0.5)
    }
    
    @IBAction func keyReleased(_ sender: UIButton) {
        switch sender {
        case firstKey:
            self.soundBox.removeActiveNote(.C)
            
        case secondKey:
            self.soundBox.removeActiveNote(.D)
            
        case thirdKey:
            self.soundBox.removeActiveNote(.E)
            
        case fourthKey:
            self.soundBox.removeActiveNote(.F)
            
        default:
            self.soundBox.removeActiveNote(.G)
        }
        
        //self.soundBox.stopPlaying()
    }
    
    @IBAction func sideAccepted(_ sender: UIButton) {
        self.pairConfirmationButton.isHidden = true
        
        self.soundBox.service.acceptPairingWith(peerId: self.peerId!, as: self.side)
    }
}
