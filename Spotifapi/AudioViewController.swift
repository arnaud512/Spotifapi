//
//  AudioViewController.swift
//  Spotifapi
//
//  Created by Arnaud Dupuy on 31/10/2016.
//  Copyright © 2016 Arnaud Dupuy. All rights reserved.
//

import UIKit

class AudioViewController: UIViewController {
    
    var track: Track!

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var trackTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImage.image = track.image
        trackImage.image = track.image
        trackTitle.text = track.title
    }
    
        
}
