//
//  FavBusTableViewController.swift
//  BusPlusA
//
//  Created by iui on 2019/12/9.
//  Copyright © 2019 Carolyn Yu. All rights reserved.
//

import UIKit

class FavBusTableViewController: UITableViewController {

    let favBusList = ["棕 9 南京幹線", "2 3 6 羅斯福路幹線"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "常用公車"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "編輯", style: .done, target: self, action: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return favBusList.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchBusResultCell", for: indexPath) as! SearchBusResultCell

        cell.busNameLabel.text = favBusList[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let favBusStopView = storyboard?.instantiateViewController(withIdentifier: "searchBusStopViewID") as! SearchBusStopListViewController
        favBusStopView.isFromFav = 1
        favBusStopView.busName = self.favBusList[indexPath.row]

        navigationController?.pushViewController(favBusStopView, animated: true)
    }

}
