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
    @IBOutlet weak var searchBar: UISearchBar!

    var _searchUrl = ""
    var searchUrl: String {
        get {
            return _searchUrl
        }
        set {
            print(newValue)
            _searchUrl = "https://api.spotify.com/v1/search?q=\(newValue)&type=track"
        }
    }
    
    var tracks = [Track]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Spotifapi"
        playerContainer.isHidden = true
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
                            var artistsNames = [String]()
                            if let artists = album["artists"] as? [JSONStandard] {
                                for artist in artists {
                                    artistsNames.append("\(artist["name"]!)")
                                }
                            }
                            if let images = album["images"] as? [JSONStandard] {
                                let imageData = images[0]
                                
                                let mainImageURL = URL(string: imageData["url"] as! String)
                                URLSession.shared.dataTask(with: mainImageURL!, completionHandler: { (data, response, error) in
                                    DispatchQueue.main.async(execute: { () -> Void in
                                        let mainImage = UIImage(data: data!)
                                        self.tracks.append(Track.init(title: name, artists: artistsNames, image: mainImage, previewUrl: previewURL))
                                        self.tableView.reloadData()

                                    })
                                }).resume()
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
        playerContainer.isHidden = false
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

extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        if let keywords = searchBar.text {
            searchUrl = keywords.replacingOccurrences(of: " ", with: "+")
            tracks.removeAll()
            tableView.reloadData()
            self.callAlamo(url: self.searchUrl)
        }
    }
}

