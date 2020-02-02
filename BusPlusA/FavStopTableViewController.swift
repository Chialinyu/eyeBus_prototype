//
//  FavStopTableViewController.swift
//  BusPlusA
//
//  Created by iui on 2020/2/2.
//  Copyright © 2020 Carolyn Yu. All rights reserved.
//

import UIKit

class favStopsTableViewCell:UITableViewCell {
    @IBOutlet weak var favStopLabel: UILabel!
}

class FavStopTableViewController: UITableViewController {
    
    let favStopList = ["捷運南京復興站", "台北車站(開封)"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "常用站牌"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "編輯", style: .done, target: self, action: nil)
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return favStopList.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favStopsTableCell", for: indexPath) as! favStopsTableViewCell

        cell.favStopLabel.text = favStopList[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let favStopBusListView = storyboard?.instantiateViewController(withIdentifier: "favStopBuseListViewID") as! FavStopBusListTableViewController
        
        favStopBusListView.busStop = favStopList[indexPath.row]
        
        navigationController?.pushViewController(favStopBusListView, animated: true)
    }

}
