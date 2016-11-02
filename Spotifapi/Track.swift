//
//  Track.swift
//  Spotifapi
//
//  Created by Arnaud Dupuy on 31/10/2016.
//  Copyright © 2016 Arnaud Dupuy. All rights reserved.
//

import UIKit

struct Track {
    let title: String!
    let artists: [String]!
    let image: UIImage!
    let previewUrl: URL!
}

func ==(track1: Track, track2: Track) -> Bool {
    return track1.previewUrl == track2.previewUrl
}
