//
//  HomeTableViewController.swift
//  BusPlusA
//
//  Created by iui on 2019/12/3.
//  Copyright © 2019 Carolyn Yu. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell{
    
//    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var functionLabel: UILabel!
    
}

class HomeTableViewController: UITableViewController {
    
//    var functionCell = ["規劃路線", "附近站牌", "搜尋公車", "常用公車", "常用站牌"]
    var functionCell = ["常用路線", "規劃路線", "附近站牌", "搜尋公車", "常用公車", "常用站牌"]
//    var iconList = ["home_icon_circle", "home_icon_cross", "home_icon_triangle", "home_icon_square", "home_icon_square", "home_icon_square"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
                
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:"說明", style:.done, target: self, action: #selector(addTapped))
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = "使用說明"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"設定", style:.done, target: self, action: nil)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    @objc func addTapped(){
        let aboutView = storyboard?.instantiateViewController(withIdentifier: "aboutID") as! AboutViewController
        navigationController?.pushViewController(aboutView, animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return functionCell.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as! HomeTableViewCell

//        cell.iconImg.image =  UIImage(named: iconList[indexPath.row])
        cell.functionLabel.text = functionCell[indexPath.row]
        cell.backgroundView = UIImageView(image: UIImage(named: "home_Cell_Bg"))
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return (tableView.frame.height - (navigationController?.navigationBar.frame.height ?? 0.0) - UIApplication.shared.statusBarFrame.height ) / CGFloat( functionCell.count)
        return tableView.frame.height / CGFloat( functionCell.count)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        
        // favorite routes
        case 0:
            let favListView = storyboard?.instantiateViewController(withIdentifier: "favListTableView") as! FavoriteListTableViewController
            navigationController?.pushViewController(favListView, animated: true)
            
        case 1:
            let directionView = storyboard?.instantiateViewController(withIdentifier: "directionViewID") as! DirectionsViewController
            navigationController?.pushViewController(directionView, animated: true)
            
        case 2:
            let nearbyStopsView = storyboard?.instantiateViewController(withIdentifier: "nearbyListID") as! StopsNearbyTableViewController
            navigationController?.pushViewController(nearbyStopsView, animated: true)
        case 3:
        let searchBusView = storyboard?.instantiateViewController(withIdentifier: "searchBusViewID") as! SearchBusViewController
        navigationController?.pushViewController(searchBusView, animated: true)
            
        case 4:
            let favBusView = storyboard?.instantiateViewController(withIdentifier: "favBusViewID") as! FavBusTableViewController
            navigationController?.pushViewController(favBusView, animated: true)
        
        case 5:
            let favStopView = storyboard?.instantiateViewController(withIdentifier: "favStopViewID") as! FavStopTableViewController
            navigationController?.pushViewController(favStopView, animated: true)
            
        default:
            break
        }
    }

}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
