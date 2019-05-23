//
//  PreferencesWindowController.swift
//  Tempora
//
//  Created by Matthew Poulos on 4/22/19.
//  Copyright © 2019 Equulus. All rights reserved.
//

import Cocoa

// enum
struct PreferenceKey {
    static let sessionLength = "sessionLength"
    static let breakCount = "breakCount"
    static let breakLength = "breakLength"
    static let sessionSoundPath = "sessionSoundPath"
    static let breakSoundPath = "breakSoundPath"
}

class PreferencesWindowController: NSObject, NSWindowDelegate {
   
   let defaults = UserDefaults()
    
    @IBOutlet weak var sessionLengthTextField: NSTextField!
    @IBOutlet weak var breakCountTextField: NSTextField!
    @IBOutlet weak var breakLengthTextField: NSTextField!
    
    //we present length in minutes, but store in seconds
    override func awakeFromNib() {
        
        //populate the values from defaults
        sessionLengthTextField.doubleValue = defaults.double(forKey: PreferenceKey.sessionLength) / 60.0
        breakCountTextField.intValue = Int32(defaults.integer(forKey: PreferenceKey.breakCount))
        breakLengthTextField.doubleValue = defaults.double(forKey: PreferenceKey.breakLength) / 60.0
        
        
    }
    
    @IBAction func sessionLengthChanged(_ sender: NSTextField) {
        defaults.set(sender.doubleValue*60.0, forKey: PreferenceKey.sessionLength)
        defaults.synchronize()
    }
    
    @IBAction func breaksChanged(_ sender: NSTextField) {
        defaults.set(sender.intValue, forKey:PreferenceKey.breakCount)
        defaults.synchronize()
    }
    
    @IBAction func breakLengthChanged(_ sender: NSTextField) {
        defaults.set(sender.doubleValue*60.0, forKey:PreferenceKey.breakLength)
        defaults.synchronize()
    }
    
    
}
