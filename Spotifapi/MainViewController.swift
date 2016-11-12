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
    @IBOutlet weak var playerContainerBottomConstraint: NSLayoutConstraint!
    
    typealias JSONStandard = [String : AnyObject]
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var queryId: Int!
    var _searchUrl = ""
    var searchUrl: String {
        get {
            return _searchUrl
        }
        set {
            _searchUrl = "https://api.spotify.com/v1/search?q=\(newValue)&type=track"
        }
    }
    var nextUrl: String?
    
    var tracks = [Track]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Spotifapi"
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCells), name: PlayerViewController.playerUpdateNotification, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func callAlamo(url: String) {
        queryId = Int(arc4random())
        Alamofire.request(url).responseJSON { response in
            self.parseData(JSONData: response.data!)
        }
    }
    
    func parseData(JSONData: Data) {
        do {
            let id = queryId
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            if let tracks = readableJSON["tracks"] as? JSONStandard {
                if let next = tracks["next"] as? String {
                    self.nextUrl = next
                }
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
                                        if id == self.queryId {
                                            self.tracks.append(Track.init(title: name, artists: artistsNames, image: mainImage, previewUrl: previewURL))
                                            self.tableView.reloadData()
                                        }
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
        updateCell(cell: cell, atIndexPath: indexPath)
        
        let imageView = cell?.viewWithTag(2) as! UIImageView
        imageView.image = track.image
        
        let artists = cell?.viewWithTag(3) as! UILabel
        artists.text = track.artists.joined(separator: ", ")
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = tracks[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        tooglePlayerContainer(isHidden: false)
        player.play(track: track)
        
        updateCells()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tracks.count - 1, let next = nextUrl {
            callAlamo(url: next)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.tableView.indexPathForSelectedRow
        if segue.identifier == "showTrack" {
            let audioVC = segue.destination as! AudioViewController
            let track = tracks[(indexPath?.row)!]
            audioVC.track = track
        }
    }
    
    @IBAction func playAllButton(_ sender: Any) {
        tooglePlayerContainer(isHidden: false)
        player.play(playlist: Playlist(playlist: tracks))
    }
    
    func updateCell(cell: UITableViewCell?, atIndexPath indexPath: IndexPath) {
        if let cell = cell, let track = player.track {
            let title = cell.viewWithTag(1) as! UILabel
            if tracks[indexPath.row] == track {
                title.textColor = UIColor(red:0.215, green:0.676, blue:0.386, alpha:1)
                title.font = UIFont.boldSystemFont(ofSize: 25.0)
            } else {
                title.textColor = .black
                title.font = UIFont.systemFont(ofSize: 17)
            }
        }
    }
    
    func updateCells() {
        if let indexPaths = tableView.indexPathsForVisibleRows{
            for indexPath in indexPaths {
                let cell = tableView.cellForRow(at: indexPath)
                updateCell(cell: cell, atIndexPath:  indexPath)
            }
        }
        
    }
    
    func tooglePlayerContainer(isHidden: Bool) {
        let inset: CGFloat = isHidden ? -80 : 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.tableView.contentInset = UIEdgeInsetsMake(64, 0, inset + 80, 0)
            self.playerContainerBottomConstraint.constant = inset
            self.view.layoutIfNeeded()
        }, completion: nil)
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

