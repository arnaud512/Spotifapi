//
//  Player.swift
//  Spotifapi
//
//  Created by Arnaud Dupuy on 31/10/2016.
//  Copyright © 2016 Arnaud Dupuy. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

protocol PlayerDelegate {
    func updateUI(type: Player.updateUIType)
}

class Player: NSObject {
    
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var audioRatePitch: AVAudioUnitTimePitch!
    var audioFile: AVAudioFile!
    
    var track: Track?
    var delegate: PlayerDelegate?
    var isReadyToPlay: Bool = false {
        didSet {
            delegate?.updateUI(type: .lecture)
        }
    }
    
    override init() {
        super.init()
        /*let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(true)
            
            let commandCenter = MPRemoteCommandCenter.shared()
            commandCenter.pauseCommand.isEnabled = true
            commandCenter.pauseCommand.addTarget(self, action: #selector(pauseCC))
            
            commandCenter.playCommand.isEnabled = true
            commandCenter.playCommand.addTarget(self, action: #selector(playCC))
            
            commandCenter.nextTrackCommand.isEnabled = false
            commandCenter.nextTrackCommand.addTarget(self, action: #selector(nextCC))
        } catch {
            print(error)
        }*/
    }
        
    func play(track: Track, isPlaylist: Bool = false) {
        if isReadyToPlay {
            audioEngine.stop()
        }
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
            // TODO: audioPlayer.delegate = self
            audioEngine = AVAudioEngine()
            audioRatePitch = AVAudioUnitTimePitch()
            audioRatePitch.pitch = 600
            audioPlayerNode = AVAudioPlayerNode()
            
            audioEngine.attach(audioRatePitch)
            audioEngine.attach(audioPlayerNode)
            
            audioEngine.connect(audioPlayerNode, to: audioRatePitch, format: nil)
            audioEngine.connect(audioRatePitch, to: audioEngine.outputNode, format: nil)
            
            audioFile = try AVAudioFile(forReading: url)
            try audioEngine.start()
            
            audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
            audioPlayerNode.play()
            
            //updateCC()
            isReadyToPlay = true
        } catch {
            print(error)
        }
    }
    
    func setPlayerTo(position: Float) {
        /*if isReadyToPlay {
            let time = TimeInterval(position) * audioPlayer.duration
            audioPlayerNode.currentTime = time
        }*/
    }
    
    // MARK: Playlist
    
    var isPlaylist = false
    var playlist: Playlist?
    
    func play(playlist: Playlist) {
        self.playlist = playlist
        playNext()
    }
    
    func playNext() {
        if let track = playlist?.next() {
            self.play(track: track, isPlaylist: true)
        }
    }
    
    // MARK: ControlCenter
    
    /*private func updateCC(isPause: Bool = false) {
        let commandCenter = MPRemoteCommandCenter.shared()
        if isPlaylist {
            commandCenter.nextTrackCommand.isEnabled = playlist?.hasNext ?? false
        } else {
            commandCenter.nextTrackCommand.isEnabled = false
        }
        
        let artwork = MPMediaItemArtwork(boundsSize: track!.image.size, requestHandler: { (size) -> UIImage in
            return self.track!.image
        })
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyArtist: track!.artists.joined(separator: ", "),
            MPMediaItemPropertyTitle: track!.title,
            MPMediaItemPropertyPlaybackDuration: audioPlayer.duration,
            MPNowPlayingInfoPropertyPlaybackRate: NSNumber(value: isPause ? 0 : 1),
            MPNowPlayingInfoPropertyElapsedPlaybackTime: audioPlayer.currentTime,
            MPMediaItemPropertyArtwork: artwork,
        ]
    }
    
    func playCC() {
        if isReadyToPlay {
            audioPlayer.play()
            updateCC()
        }
    }
    
    func pauseCC() {
        if isReadyToPlay {
            audioPlayer.pause()
            updateCC(isPause: true)
        }
    }
    
    func nextCC() {
        if isReadyToPlay {
            playNext()
        }
    }*/

}

extension Player: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if isPlaylist {
            playNext()
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
