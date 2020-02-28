//
//  StopsNearbyTableViewController.swift
//  BusPlusA
//
//  Created by iui on 2019/12/8.
//  Copyright © 2019 Carolyn Yu. All rights reserved.
//

import UIKit

class StopsNearbyTableViewCell:UITableViewCell {
    @IBOutlet weak var nearbyStopLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
}

class StopsNearbyTableViewController: UITableViewController {
   
    let nearbyStops = ["市立體育場", "臺視", "捷運南京復興站", "八德敦化路口"]
    let distances = ["45", "103", "204", "304"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "附近站牌"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return nearbyStops.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 116
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nearbyCellID", for: indexPath) as! StopsNearbyTableViewCell

        cell.nearbyStopLabel.text = nearbyStops[indexPath.row]
        cell.distanceLabel.text = "距離 " + distances[indexPath.row] + " 公尺"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let nearbyBusListView = storyboard?.instantiateViewController(withIdentifier: "stopNbBuseListViewID") as! StopsNearbyBusListTableViewController
        
        nearbyBusListView.busStop = self.nearbyStops[indexPath.row]
        
        navigationController?.pushViewController(nearbyBusListView, animated: true)
    }

}
