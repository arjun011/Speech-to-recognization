//
//  ViewController.swift
//  Utter
//
//  Created by Akruti Panchal on 11/09/19.
//  Copyright © 2019 Akruti Panchal. All rights reserved.
//

import UIKit
import Speech
class ViewController: UIViewController {

    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var lblSpeechText: UILabel!
    @IBOutlet weak var btnStartSpeech: UIButton!
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestSpeechAuthorization()
    }
    
    @IBAction func btnStartRecording(_ sender: Any) {
        if isRecording == true {
            cancelRecording()
            isRecording = false
            btnStartSpeech.backgroundColor = UIColor.gray
        } else {
            self.recordAndRecognizeSpeech()
            isRecording = true
            btnStartSpeech.backgroundColor = UIColor.red
        }
    }

    func cancelRecording() {
        recognitionTask?.finish()
        recognitionTask = nil
        
        // stop audio
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    //MARK: - Recognize Speech
    func recordAndRecognizeSpeech() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            self.sendAlert(message: "There has been an audio engine error.")
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            self.sendAlert(message: "Speech recognition is not supported for your current locale.")
            return
        }
        if !myRecognizer.isAvailable {
            self.sendAlert(message: "Speech recognition is not currently available. Check back at a later time.")
            // Recognizer is not available right now
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                
                let bestString = result.bestTranscription.formattedString
                self.lblSpeechText.text = bestString
                
                var lastString: String = ""
                for segment in result.bestTranscription.segments {
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    lastString = bestString.substring(from: indexTo)
                }
                self.checkForColorsSaid(resultString: lastString)
            } else if let error = error {
                self.sendAlert(message: "There has been a speech recognition error.")
                print(error)
            }
        })
    }
    
    //MARK: - Check Authorization Status
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.btnStartSpeech.isEnabled = true
                case .denied:
                    self.btnStartSpeech.isEnabled = false
                    self.lblSpeechText.text = "User denied access to speech recognition"
                case .restricted:
                    self.btnStartSpeech.isEnabled = false
                    self.lblSpeechText.text = "Speech recognition restricted on this device"
                case .notDetermined:
                    self.btnStartSpeech.isEnabled = false
                    self.lblSpeechText.text = "Speech recognition not yet authorized"
                }
            }
        }
    }
    
    //MARK: - UI / Set view color.
    
    func checkForColorsSaid(resultString: String) {
        switch resultString {
        case "red":
            colorView.backgroundColor = UIColor.red
        case "orange":
            colorView.backgroundColor = UIColor.orange
        case "yellow":
            colorView.backgroundColor = UIColor.yellow
        case "green":
            colorView.backgroundColor = UIColor.green
        case "blue":
            colorView.backgroundColor = UIColor.blue
        case "purple":
            colorView.backgroundColor = UIColor.purple
        case "black":
            colorView.backgroundColor = UIColor.black
        case "white":
            colorView.backgroundColor = UIColor.white
        case "gray":
            colorView.backgroundColor = UIColor.gray
        default: break
        }
    }
    
    //MARK: - Alert
    
    func sendAlert(message: String) {
        let alert = UIAlertController(title: "Speech Recognizer Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController:SFSpeechRecognizerDelegate {
    
}

