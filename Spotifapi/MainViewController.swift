//
//  ViewController.swift
//  Spotifapi
//
//  Created by Arnaud Dupuy on 31/10/2016.
//  Copyright © 2016 Arnaud Dupuy. All rights reserved.
//

import UIKit
import Alamofire

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var playerContainer: UIView!
    
    typealias JSONStandard = [String : AnyObject]
    
    @IBOutlet weak var tableView: UITableView!

    let searchUrl = "https://api.spotify.com/v1/search?q=Muse&type=track"
    var tracks = [Track]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Spotifapi"
        
        // TODO: make this non-blocking
        self.callAlamo(url: self.searchUrl)
    }
    
    func callAlamo(url: String) {
        Alamofire.request(url).responseJSON { response in
            self.parseData(JSONData: response.data!)
        }
    }
    
    func parseData(JSONData: Data) {
        do {
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            if let tracks = readableJSON["tracks"] as? JSONStandard {
                if let items = tracks["items"] as? [JSONStandard] {
                    for item in items {
                        let name = item["name"] as! String
                        let previewURL = URL(string: item["preview_url"] as! String)!
                        if let album = item["album"] as? JSONStandard {
                            if let images = album["images"] as? [JSONStandard] {
                                let imageData = images[1]
                                
                                let mainImageURL = URL(string: imageData["url"] as! String)
                                let mainImageData = NSData(contentsOf: mainImageURL!)
                                
                                let mainImage = UIImage(data: mainImageData as! Data)
                                self.tracks.append(Track.init(title: name, image: mainImage, previewUrl: previewURL))
                                self.tableView.reloadData()
                            }
                        }
                        
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let track = tracks[indexPath.row]
        
        let title = cell?.viewWithTag(1) as! UILabel
        title.text = track.title
        
        let imageView = cell?.viewWithTag(2) as! UIImageView
        imageView.image = track.image
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = tracks[indexPath.row]
        player.play(track: track)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.tableView.indexPathForSelectedRow
        if segue.identifier == "showTrack" {
            let audioVC = segue.destination as! AudioViewController
            let track = tracks[(indexPath?.row)!]
            audioVC.track = track
        }
        
        
    }
    
}
