//
//  PlayerViewController.swift
//  Spotifapi
//
//  Created by Arnaud Dupuy on 31/10/2016.
//  Copyright © 2016 Arnaud Dupuy. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController, PlayerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var lectureButton: UIButton!
    @IBOutlet weak var progressBarView: PlayerProgressBarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player.delegate = self
        lectureButton.tintColor = .white
        lectureButton.setImage(nil, for: .normal)
        let progressBarTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) {_ in
            self.updateProgressBar()
        }
        RunLoop.current.add(progressBarTimer, forMode: .commonModes)
    }
    
    @IBAction func toogleLecture(_ sender: Any) {
        if player.audioPlayer.isPlaying {
            player.audioPlayer.pause()
            
        } else {
            player.audioPlayer.play()
        }
        updateLectureButton()
    }
    
    func updateUI(type: Player.updateUIType) {
        if type == .data {
            if let track = player.track {
                titleLabel.text = track.title
                imageView.image = track.image
            }
        }
        if type == .lecture {
            updateLectureButton()
        }
        
    }
    
    func updateLectureButton() {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                if player.isReadyToPlay {
                    if player.audioPlayer.isPlaying {
                        self.lectureButton.setImage(#imageLiteral(resourceName: "pause-button"), for: .normal)
                    } else {
                        self.lectureButton.setImage(#imageLiteral(resourceName: "play-button"), for: .normal)
                    }
                }
            }
        }
        
    }
    
    func updateProgressBar() {
        if player.isReadyToPlay {
            let progressPosition = player.audioPlayer.currentTime / player.audioPlayer.duration
            progressBarView.progress = Double(progressPosition)
        }
    }

}
