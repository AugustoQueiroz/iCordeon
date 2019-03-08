//
//  SoundBox.swift
//  iCordeon
//
//  Created by Augusto Queiroz on 20/02/19.
//  Copyright © 2019 Augusto Queiroz. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class SoundBox: NSObject, BoxServiceDelegate {
    let service = BoxService()
    let accordionSynth = AccordionMIDIPlayer()
    var delegate: SoundBoxDelegate?
    
    private let sounds = [""]
    
    var activeNotes: Set<Note> = []
    
    override init() {
        super.init()
        self.service.delegate = self
    }
    
    func askToAcceptPairing(with peerId: MCPeerID, as position: BoxSide) {
        if let delegate = self.delegate {
            delegate.askToAcceptPairing(with: peerId, as: position)
        }
    }
    
    func play(withIntensity intensity: Double) {
        var velocity = UInt8(((intensity * 100) < Double(UInt8.max)) ? intensity * 100 : Double(UInt8.max))
        if velocity + 80 > 255 {
            velocity = 255
        } else {
            velocity += 80
        }
        
        print(velocity)
        
        for note in self.activeNotes {
            self.accordionSynth.noteOn(note, velocity: velocity)
        }
    }
    
    func stopPlaying() {
        for note in self.activeNotes {
            self.accordionSynth.noteOff(note)
        }
        
        self.accordionSynth.stop()
    }
    
    func addActiveNote(_ note: Note) {
        self.activeNotes.insert(note)
    }
    
    func removeActiveNote(_ note: Note) {
        self.activeNotes.remove(note)
        self.accordionSynth.noteOff(note)
    }
}
