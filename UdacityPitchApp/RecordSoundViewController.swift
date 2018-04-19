//
//  RecordSoundViewController.swift
//  UdacityPitchApp
//
//  Created by Kynan Song on 17/04/2018.
//  Copyright © 2018 Kynan Song. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundViewController: UIViewController, AVAudioRecorderDelegate {

    var audioRecorder: AVAudioRecorder!
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var recordingTimer: UILabel!
    
    var counter = 0.0
    var timer = Timer()
    var isCounting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stopRecordingButton.isEnabled = false
    }
    
    
    func configureUI(recordingState: Bool) {
        if recordingState == true {
            recordingLabel.text = "Recording in Progress"
            stopRecordingButton.isEnabled = true
            recordButton.isEnabled = false
            
            counter = 0.0
            recordingTimer.text = String(counter)
            //Resets counter when pressed.
            //Need to fix UI for counter.
        
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            isCounting = true
            
        } else {
            recordingLabel.text = "Press to Record"
            stopRecordingButton.isEnabled = false
            recordButton.isEnabled = true
            timer.invalidate()
            isCounting = false
        }
    }
    
    @objc func updateTimer() {
        counter = counter + 0.1
        recordingTimer.text = String(format: "%.1f", counter)
    }
    


    @IBAction func recordAudio(_ sender: Any) {

        configureUI(recordingState: true)
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        //Joins dirPath and the file name to provide the url file path.
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func stopRecording(_ sender: Any) {

        configureUI(recordingState: false)
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
        performSegue(withIdentifier: "recordingFinished", sender: audioRecorder.url)
        } else {
            print("recording failed")
        }
            
        //called as this view controller is its delegate.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recordingFinished" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController //forced upcast as we know where it is going.
            let recordAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordAudioURL
        }
    }
    
}

