//
//  DetailViewController.swift
//  English - Turkish Dictionary
//
//  Created by quoccuong on 8/1/18.
//  Copyright © 2018 quoccuong. All rights reserved.
//

import UIKit
import AVFoundation
class DetailViewController: UIViewController {

    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var definitionLabel: UILabel!
    var speechUtterance : AVSpeechUtterance!
    var speechSynthesize = AVSpeechSynthesizer()
    var voice: String?
    var detailWord: Word? {
        didSet {
            configureView()
            configureVoice()
        }
    }


    func configureView() {
        if let detailWord = detailWord {
            if let wordLabel = wordLabel, let definitionLabel = definitionLabel {
                wordLabel.text = detailWord.word
                definitionLabel.text = detailWord.definitionString
            }
        }
    }
    
    func configureVoice() {
        if let detailWord = detailWord {
            let language = detailWord.language
            let textToSpeak = detailWord.word
            if language == 1 {
                voice = "tr-TR"
            } else {
                voice = "en-US"
            }
            self.speechUtterance = AVSpeechUtterance(string: textToSpeak)
            self.speechUtterance.voice = AVSpeechSynthesisVoice(language: voice)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.alpha = 0.1
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func speak(_ sender: Any) {
            speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 3.0
            speechSynthesize.speak(speechUtterance)
    }


}

