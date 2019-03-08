//
//  AccordionMIDIPlayer.swift
//  iCordeon
//
//  Created by Augusto Queiroz on 22/02/19.
//  Copyright © 2019 Augusto Queiroz. All rights reserved.
//

import Foundation
import AudioKit

class AccordionMIDIPlayer {
    let bank = AKOscillatorBank()
    var envelope: AKAmplitudeEnvelope!
    
    init() {
        self.envelope = AKAmplitudeEnvelope(self.bank)
//        self.bank.attackDuration = 0.01
//        self.bank.decayDuration = 0.1
//        self.bank.sustainLevel = 0.1
//        self.bank.releaseDuration = 0.3
        
        do {
            AudioKit.output = self.bank
            try AudioKit.start()
        } catch let error {
            print(error)
        }
    }
    
    func noteOn(_ note: Note, velocity: UInt8 = 80) {
        let noteNumber = UInt8(note.rawValue.frequencyToMIDINote())
        self.bank.play(noteNumber: noteNumber, velocity: velocity)
    }
    
    func noteOff(_ note: Note) {
        let noteNumber = UInt8(note.rawValue.frequencyToMIDINote())
        self.bank.stop(noteNumber: noteNumber)
    }
    
    func stop() {
        /*do {
            try AudioKit.stop()
        } catch let error {
            print(error)
        }*/
    }
}
