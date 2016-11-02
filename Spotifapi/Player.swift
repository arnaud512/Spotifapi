//
//  Player.swift
//  Spotifapi
//
//  Created by Arnaud Dupuy on 31/10/2016.
//  Copyright © 2016 Arnaud Dupuy. All rights reserved.
//

import Foundation
import AVFoundation

protocol PlayerDelegate {
    func updateUI(type: Player.updateUIType)
}

class Player: NSObject {
    
    var audioPlayer = AVAudioPlayer()
    var track: Track?
    var delegate: PlayerDelegate?
    var isReadyToPlay: Bool = false {
        didSet {
            delegate?.updateUI(type: .lecture)
        }
    }
        
    func play(track: Track, isPlaylist: Bool = false) {
        self.isPlaylist = isPlaylist
        self.track = track
        delegate?.updateUI(type: .data)
        downloadFileFromUrl(url: track.previewUrl)
    }
    
    private func downloadFileFromUrl(url: URL) {
        var downloadTask = URLSessionDownloadTask()
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (url, response, error) in
            self.play(url: url!)
        })
        downloadTask.resume()
    }
    
    private func play(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            isReadyToPlay = true
        } catch {
            print(error)
        }
    }
    
    // MARK: Playlist
    
    var isPlaylist = false
    var playlist: Playlist?
    
    func play(playlist: Playlist) {
        self.playlist = playlist
        playNext()
    }
    
    private func playNext() {
        if let track = playlist?.next() {
            self.play(track: track, isPlaylist: true)
        }
    }

}

extension Player: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if isPlaylist {
            if let track = playlist?.next() {
                self.play(track: track, isPlaylist: true)
            }
        }
        delegate?.updateUI(type: .lecture)
    }
}

extension Player {
    enum updateUIType {
        case data
        case lecture
    }
}
