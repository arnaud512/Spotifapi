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
    
    var audioEngine = AVAudioEngine()
    var audioPlayerNode = AVAudioPlayerNode()
    var audioRatePitch = AVAudioUnitTimePitch()
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
        audioEngine.attach(audioRatePitch)
        audioEngine.attach(audioPlayerNode)
        audioRatePitch.pitch = 0
        audioEngine.connect(audioPlayerNode, to: audioRatePitch, format: nil)
        audioEngine.connect(audioRatePitch, to: audioEngine.outputNode, format: nil)
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(true)
            
            /*let commandCenter = MPRemoteCommandCenter.shared()
            commandCenter.pauseCommand.isEnabled = true
            commandCenter.pauseCommand.addTarget(self, action: #selector(pauseCC))
            
            commandCenter.playCommand.isEnabled = true
            commandCenter.playCommand.addTarget(self, action: #selector(playCC))
            
            commandCenter.nextTrackCommand.isEnabled = false
            commandCenter.nextTrackCommand.addTarget(self, action: #selector(nextCC))*/
        } catch {
            print(error)
        }
    }
        
    func play(track: Track, isPlaylist: Bool = false) {
        if isReadyToPlay {
            resetAudioEngineAndPlayer()
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
            
            audioFile = try AVAudioFile(forReading: url)
            let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
            try audioFile.read(into: buffer)
                
            audioPlayerNode.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: {
                self.audioPlayerNodeDidFinishPlaying()
            })
            try audioEngine.start()
            audioPlayerNode.play()
            
            //updateCC()
            isReadyToPlay = true
        } catch {
            print(error)
        }
    }
    
    func setPlayerTo(position: Double) {
        if isReadyToPlay {
            let time = TimeInterval(position * audioFile.fileFormat.sampleRate) * currentLength()
            audioFile.framePosition = AVAudioFramePosition(time)
            let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(audioFile.length))
            do {
                try audioFile.read(into: buffer)
            } catch {
                    
            }
            audioPlayerNode.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: {
                self.audioPlayerNodeDidFinishPlaying()
            })

            audioPlayerNode.play()
        }
        print(currentLength())
    }
    
    func currentTime() -> TimeInterval {
        if let nodeTime: AVAudioTime = audioPlayerNode.lastRenderTime, let playerTime: AVAudioTime = audioPlayerNode.playerTime(forNodeTime: nodeTime) {
            return Double(Double(playerTime.sampleTime) / playerTime.sampleRate)
        }
        return 0
    }
    
    func currentLength() -> TimeInterval {
        if let nodeTime: AVAudioTime = audioPlayerNode.lastRenderTime, let playerTime: AVAudioTime = audioPlayerNode.playerTime(forNodeTime: nodeTime) {
            return Double(Double(audioFile.length) / playerTime.sampleRate)
        }
        return 0
    }
    
    func currentPosition() -> Double {
        let time = currentTime()
        let length = currentLength()
        if length != 0 {
            return Double(time / length)
        }
        return 0
    }
    
    func audioPlayerNodeDidFinishPlaying() {
        resetAudioEngineAndPlayer()
        if isPlaylist {
            playNext()
        }
        delegate?.updateUI(type: .lecture)
    }
    
    func resetAudioEngineAndPlayer() {
        audioPlayerNode.stop()
        audioEngine.stop()
        audioEngine.reset()
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

extension Player {
    enum updateUIType {
        case data
        case lecture
    }
}
