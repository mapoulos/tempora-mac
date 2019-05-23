//
//  StatusMenuController.swift
//  Tempora
//
//  Created by Matthew Poulos on 4/18/19.
//  Copyright © 2019 Equulus. All rights reserved.
//

import Cocoa
import AVFoundation

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    @IBOutlet weak var timeMenuItem: NSMenuItem!
    let defaults = UserDefaults()
    
    var soundLibrary: TimerSoundLibrary  {
        let soundBundle = Bundle(path: Bundle.main.path(forResource: "Sounds", ofType: "bundle")!)
        TimerSoundLibrary.initialize(soundBundle: soundBundle!, manifestName: "manifest", withExtension: "json")
        return TimerSoundLibrary.getInstance()!
    }
    var sessionSound: TimerSound?
    var breakSound: TimerSound?
    
    
    var workSession = WorkSession()
    
    private func produceFormattedTimeString() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .brief
        formatter.allowedUnits = [.minute, .second]
        
        let sessionTimeRemaining = formatter.string(from: workSession.getSessionDuration() -  workSession.getElapsedTimeSession())
        //let durToBreak = workSession.getDurationToBreak()
        //let elapTimeToBreak = workSession.getElapsedTimeToBreak()
        let timeToBreak = formatter.string(from: workSession.getDurationToBreak() - workSession.getElapsedTimeToBreak())
        
        
        if(workSession.started()) {
            if(workSession.breakInProgress()) {
                let breakTime = formatter.string(from: workSession.getBreakDuration() - workSession.getElapsedTimeInBreak())
                
                return "(" + breakTime! + " remaining in break)"
            } else {
                if(workSession.breakRemaining()) {
                    return sessionTimeRemaining! + " (" + timeToBreak! + ")"
                } else {
                    return sessionTimeRemaining! + " remaining in session"
                }
            }
        } else {
            return sessionTimeRemaining! + " (" + timeToBreak! + ")"
        }
        
        
    }
    
    func updateUI() -> () {
        
        // 30:00 (10:00)
        
        timeMenuItem.title = produceFormattedTimeString()
        
    }
    
    func updateTimersFromDefaults() {
        let sessionDuration = defaults.double(forKey: PreferenceKey.sessionLength)
        let breakDuration = defaults.double(forKey: PreferenceKey.breakLength)
        let breakCount = defaults.integer(forKey: PreferenceKey.breakCount)
        
        workSession.updateSessionParameters(sessionDuration: sessionDuration, breakDuration: breakDuration, breakCount: breakCount)
        
    }
    
    @objc func onDefaultsChange(_ notification:Notification) {
        updateTimersFromDefaults()
        updateUI()
    }
    
    /*
    print("break timer fired")
    var player: AVAudioPlayer?
    if let asset = NSDataAsset(name: "Ship_Bell") {
        do {
            
            player = try AVAudioPlayer(data: asset.data, fileTypeHint: "mp3")
            player?.play()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }*/
    
    @IBOutlet weak var sessionSoundPopUpButton: NSPopUpButton!
    @IBOutlet weak var breakSoundPopUpButton: NSPopUpButton!
    
    private func populateSoundPullDownButtons() {
        let soundNames = soundLibrary.timerSoundsDictionary.keys
        for soundName in soundNames {
            sessionSoundPopUpButton.addItem(withTitle: soundName)
            breakSoundPopUpButton.addItem(withTitle: soundName)
        }
        
        //if the sound from defaults exists, use that one. otherwise, set the first in the list
        let defaults = UserDefaults()
        let defaultsSessionSoundName = defaults.string(forKey: PreferenceKey.sessionSoundPath) ?? ""
        
        
        
        if soundNames.contains(defaultsSessionSoundName) {
            sessionSoundPopUpButton.selectItem(withTitle: defaultsSessionSoundName)
            sessionSound = soundLibrary.timerSoundsDictionary[defaultsSessionSoundName]
        } else {
            sessionSoundPopUpButton.selectItem(withTitle: soundNames.first ?? "")
            sessionSound = soundLibrary.timerSoundsDictionary[soundNames.first ?? ""]
        }
        
        let defaultsBreakSoundName = defaults.string(forKey: PreferenceKey.breakSoundPath) ?? ""
        if soundNames.contains(defaultsBreakSoundName) {
            breakSoundPopUpButton.selectItem(withTitle: defaultsBreakSoundName)
            breakSound = soundLibrary.timerSoundsDictionary[defaultsBreakSoundName]
        } else {
            breakSoundPopUpButton.selectItem(withTitle: soundNames.first ?? "")
            breakSound = soundLibrary.timerSoundsDictionary[soundNames.first ?? ""]
        }
        
    }
    
    @IBAction func sessionSoundChanged(_ sender: NSPopUpButton) {
        let newSoundName = sender.titleOfSelectedItem!
        let defaults = UserDefaults()
        defaults.set(newSoundName, forKey: PreferenceKey.sessionSoundPath)
        sessionSound = soundLibrary.timerSoundsDictionary[newSoundName]
    }
    
    @IBAction func breakSoundChanged(_ sender: NSPopUpButton) {
        let newSoundName = sender.titleOfSelectedItem!
        let defaults = UserDefaults()
        defaults.set(newSoundName, forKey: PreferenceKey.breakSoundPath)
        breakSound = soundLibrary.timerSoundsDictionary[newSoundName]
    
    }
    
    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        icon?.isTemplate = true
        statusItem.button!.image = icon
        statusItem.menu = statusMenu
        
        //set the default prefs
        let appDefaults = [PreferenceKey.sessionLength: 3600.0, PreferenceKey.breakCount: 8, PreferenceKey.breakLength: 60.0, PreferenceKey.sessionSoundPath: "Ship Bell", PreferenceKey.breakSoundPath: "Ship Bell"] as [String : Any]
        let defaults = UserDefaults()
        defaults.register(defaults: appDefaults)
        
        //register a listener
        NotificationCenter.default.addObserver(self, selector: #selector(onDefaultsChange(_:)), name: UserDefaults.didChangeNotification, object: nil)
        // create worksession
        let sessionDuration = defaults.double(forKey: PreferenceKey.sessionLength)
        let breakDuration = defaults.double(forKey: PreferenceKey.breakLength)
        let breakCount = defaults.integer(forKey: PreferenceKey.breakCount)
        
        
        
        
        //test change
        workSession = WorkSession(sessionDuration: sessionDuration, breakCount: breakCount, breakDuration: breakDuration, update: {self.updateUI()}, onSessionEnd: {self.sessionSound?.play()}, onBreakStart: {self.breakSound?.play()}, onBreakEnd: {self.breakSound?.play()}, onStop: {}, onPause: {})
        
        updateTimersFromDefaults()
        
        
        //populate the
        populateSoundPullDownButtons()
       
        // set time
        timeMenuItem.title = produceFormattedTimeString()
        
        
        
    }
    
    
    
    @IBAction func startClicked(_ sender: NSMenuItem) {
        if(workSession.started() == false) {
            // we need to start and change text to pause
            workSession.start()
            sender.title = "Pause"
            sessionSound?.play()
        } else if(workSession.started() == true && workSession.isRunning()) {
            // change from pause to Resume, pause the timers
            workSession.pause()
            sender.title = "Resume"
        } else if(workSession.started() == true && !workSession.isRunning()) {
            //change from resue to pause, resume timers
            workSession.resume()
            sender.title = "Pause"
        }
    
    }
    
    @IBOutlet weak var startMenuItem: NSMenuItem!
    @IBAction func stopClicked(_ sender: NSMenuItem) {
        
        // TODO implement
        // reset the timers
        //change the "Start" menuitem to "Start"
        startMenuItem.title = "Start"
        workSession.stop()
        updateTimersFromDefaults()
        timeMenuItem.title = produceFormattedTimeString()
        
        
       // TimerSound.playSound(assetName: "Ship_Bell")
    }
    
    
    @IBOutlet weak var preferencesPanel: NSPanel!
    
    @IBAction func preferencesClicked(_ sender: NSMenuItem) {
        let controller = NSWindowController(window: preferencesPanel)

        controller.window?.center()
        controller.window?.update()
        controller.showWindow(self)
        
        
        
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
}
