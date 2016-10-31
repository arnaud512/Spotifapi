//
//  ViewController.swift
//  Spotifapi
//
//  Created by Arnaud Dupuy on 31/10/2016.
//  Copyright © 2016 Arnaud Dupuy. All rights reserved.
//

import UIKit
import Alamofire

class MainTableViewController: UITableViewController {
    
    typealias JSONStandard = [String : AnyObject]

    let searchUrl = "https://api.spotify.com/v1/search?q=Muse&type=track"
    var names = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Spotifapi"
        callAlamo(url: searchUrl)
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
                        names.append(name)
                        
                        self.tableView.reloadData()
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = names[indexPath.row]
        return cell!
    }
    
}

