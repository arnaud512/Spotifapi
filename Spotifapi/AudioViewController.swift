//
//  AudioViewController.swift
//  Spotifapi
//
//  Created by Arnaud Dupuy on 31/10/2016.
//  Copyright © 2016 Arnaud Dupuy. All rights reserved.
//

import UIKit
import AVFoundation

class AudioViewController: UIViewController {
    
    var track: Track!

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var trackTitle: UILabel!
    
    @IBOutlet weak var lectureButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImage.image = track.image
        trackImage.image = track.image
        trackTitle.text = track.title
        downloadFileFromUrl(url: track.previewUrl)
        lectureButton.setTitle("Pause", for: .normal)
    }
    
    func downloadFileFromUrl(url: URL) {
        var downloadTask = URLSessionDownloadTask()
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (url, response, error) in
            self.play(url: url!)
        })
        downloadTask.resume()
    }
    
    func play(url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
        } catch {
            print(error)
        }
    }
    
    @IBAction func lectureToogle(_ sender: Any) {
        if player.isPlaying {
            player.pause()
            lectureButton.setTitle("Play", for: .normal)
        } else {
            player.play()
            lectureButton.setTitle("Pause", for: .normal)
        }
    }

}
