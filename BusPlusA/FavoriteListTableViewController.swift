//
//  FavoriteListTableViewController.swift
//  BusPlusA
//
//  Created by iui on 2019/12/4.
//  Copyright © 2019 Carolyn Yu. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FavoriteListTableVeiwCell:UITableViewCell{
    @IBOutlet weak var favListCellBgImg: UIImageView!
    @IBOutlet weak var listIndexLabel: UILabel!
    @IBOutlet weak var startStopLabel: UILabel!
    @IBOutlet weak var endStopLabel: UILabel!
    @IBOutlet weak var transferStopLabel: UILabel!
    
}


class FavoriteListTableViewController: UITableViewController {

    var list: [String] = ["1", "2", "3"]
    var favoriteRouteStart = ["南京敦化路口", "南京敦化路口", "圓環"]
    var favoriteRouteEnd = ["圓環", "圓環", "南京敦化路口"]
    var transferStation = ["捷運松江南京站", "無", "無"]
    var routeIndex = ["route1", "route2", "route3"]
    var nextViewSectionNum = [1, 1, 1]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "常用路線列表"
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "編輯", style: .done, target: self, action: nil)


        for i in 0 ..< routeIndex.count {
            let ref = Database.database().reference().child("bus-routes").child(routeIndex[i])

            ref.observe(DataEventType.value, with: { (snapshot) in
                let retrievedDict = snapshot.value as! NSDictionary
                let stopsArray = retrievedDict["stops"] as! NSArray

                self.nextViewSectionNum[i] = stopsArray.count
                
                if(stopsArray.count > 2){
                    self.transferStation[i] = stopsArray[1] as! String
                }else{
                    self.transferStation[i] = "無"
                }

                self.favoriteRouteStart[i] = stopsArray[0] as! String
                self.favoriteRouteEnd[i] = stopsArray[stopsArray.count-1] as! String

                self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: UITableView.RowAnimation.fade)
            })
        }
        
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
        return list.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 171
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! FavoriteListTableVeiwCell

//        cell.favListCellBgImg.image = UIImage(named: "fav_Cell_Bg")
        
        cell.listIndexLabel.text = list[indexPath.row]
        cell.startStopLabel.text = favoriteRouteStart[indexPath.row]
        cell.endStopLabel.text = favoriteRouteEnd[indexPath.row]
        if transferStation[indexPath.row] != "無" {
            cell.transferStopLabel.text = "轉乘站：" + transferStation[indexPath.row]
            cell.transferStopLabel.accessibilityLabel = "。轉乘站。" + transferStation[indexPath.row]
        }else {
            cell.transferStopLabel.text = "直達車 "
            cell.transferStopLabel.accessibilityLabel = "。直達車。"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
        if transferStation[indexPath.row] == "無" {
            let routeView = storyboard?.instantiateViewController(withIdentifier: "routeContentID1") as! RouteViewController
            
            routeView.selectIndex = indexPath.row
            routeView.sectionCount = self.nextViewSectionNum[indexPath.row]
//            routeView.isFromSearch = 0
            
            navigationController?.pushViewController(routeView, animated: true)
        }

        }
}
