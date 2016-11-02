//
//  Playlist.swift
//  Spotifapi
//
//  Created by Arnaud Dupuy on 02/11/2016.
//  Copyright © 2016 Arnaud Dupuy. All rights reserved.
//

import Foundation

class Playlist {
    var playlist: [Track] = []
    
    var index = 0
    
    func next() -> Track? {
        if playlist.count > index {
            let track = playlist[index]
            index += 1
            return track
        }
        return nil
    }
    
    init(playlist: [Track]) {
        self.playlist = playlist
    }
    
}
