//
//  Route2ViewController.swift
//  BusPlusA
//
//  Created by iui on 2019/12/7.
//  Copyright © 2019 Carolyn Yu. All rights reserved.
//

import UIKit
import FirebaseDatabase

class Route2Cell:UITableViewCell {
    @IBOutlet weak var busName2Label: UILabel!
}

class Route2ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var blueIconImg: UIImageView!
    @IBOutlet weak var startStopLabel: UILabel!
    @IBOutlet weak var trabsferStopLabel: UILabel!
    @IBOutlet weak var endStopLabel: UILabel!
    @IBOutlet weak var route2TableView: UITableView!
    
    var routeIndex = ["route1", "route2", "route3"]
    var selectIndex = 1
    var sectionCount = 3 // = stop counts
    var stops = ["南京敦化路口", "捷運中山站", "圓環"]
    var buses = ["棕 9 南京幹線", "4 6", "2 8 2"]
    var times = ["10", "20", "20"]
    var busesS2 = ["棕 9 南京幹線", "4 6", "2 8 2"]
    var timesS2 = ["10", "20", "20"]
    var cellCount = [3, 3]
    var isUserArrive = false
    var nowSectionOfRoute = 0 // 紀錄現在在第幾度段旅程
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "需轉乘路線"
        
        route2TableView.delegate = self
        route2TableView.dataSource = self
        
        Database.database().reference().child("currentBusStop").setValue(0)
        
        let ref = Database.database().reference().child("bus-routes").child(routeIndex[selectIndex])

        ref.observe(DataEventType.value, with: { (snapshot) in
            let retrievedDict = snapshot.value as! NSDictionary
            let stopsArray = retrievedDict["stops"] as! NSArray
            let busesArray = retrievedDict["buses"] as! NSArray
            
            for i in 0 ..< stopsArray.count {
                self.stops[i] = stopsArray[i] as! String
            }

            DispatchQueue.global().async(execute: {
                DispatchQueue.main.async {
                    self.startStopLabel.text = "起點站  " + self.stops[0]
                    self.startStopLabel.accessibilityLabel = "起點站。" + self.stops[0]
                    self.trabsferStopLabel.text = "轉乘站  " + self.stops[1]
                    self.trabsferStopLabel.accessibilityLabel = "轉乘站。" + self.stops[1]
                    self.endStopLabel.text = "終點站  " + self.stops[self.sectionCount - 1]
                    self.endStopLabel.accessibilityLabel = "終點站。" + self.stops[self.sectionCount - 1]
                }
            })
            
            let busesSection1 = busesArray[0] as! [[String : AnyObject]]

            var index = 0
            for (busPair) in busesSection1 {
                self.buses[index] = busPair["name"] as! String
                self.times[index] = busPair["time"] as! String
                index += 1
            }
            self.cellCount[0] = index
            
            if(self.sectionCount > 2){
                let busesSection2 = busesArray[1] as! [[String : AnyObject]]

                index = 0
                for (busPair) in busesSection2 {
                    self.busesS2[index] = busPair["name"] as! String
                    self.timesS2[index] = busPair["time"] as! String
                    index += 1
                }
                self.cellCount[1] = index
            }
            
            let isUserArriveRef = Database.database().reference().child("isUserArrive")
            
            isUserArriveRef.observe(DataEventType.value, with: { (snapshot) in
                let retrievedDict = snapshot.value as? Bool
                self.isUserArrive = retrievedDict ?? self.isUserArrive
            })
            
            self.route2TableView.reloadData()
        })
        
        
        // add section
        let ref2 = Database.database().reference().child("sectionOfRoute")

        ref2.observe(DataEventType.value, with: { (snapshot) in
            let sectionOfRoute = snapshot.value as! Bool
                        
            if self.sectionCount > 2 {
                
                Database.database().reference().child("currentBusStop").setValue(0)
                
                if sectionOfRoute == true {
                    // change table section num
                    self.nowSectionOfRoute = 1
                    self.blueIconImg.image = UIImage(named: "route_blue_2")
                } else {
                    self.nowSectionOfRoute = 0
                    self.blueIconImg.image = UIImage(named: "route_blue_1")
                }
                
            } else {
                Database.database().reference().child("sectionOfRoute").setValue(0)
                self.nowSectionOfRoute = 0
                Database.database().reference().child("currentBusStop").setValue(0)
            }
            
            self.route2TableView.reloadData()
        })
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if nowSectionOfRoute == 0 {
            return sectionCount - 1 // del last sec
        } else {
            return sectionCount - 2 // del last sec
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60+24
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 60+24))
        headerView.backgroundColor = UIColor(patternImage: UIImage(named: "route_section_bg")!)
        
        let label = UILabel()
        label.frame = CGRect.init(x: 40, y: 20, width: 375-80, height: 48)
        label.numberOfLines = 0
        label.textColor = UIColor(rgb: 0xffffff)

        switch section {
        case 0:
            if nowSectionOfRoute == 0 {
                label.text = "第一段：" + stops[0] + "\n往 " + stops[1]
                label.accessibilityLabel = "第一段。" + stops[0] + "。往。" + stops[1]
            } else {
                label.text = stops[1] + "\n往 " + stops[2]
                label.accessibilityLabel = stops[1] + "。往。" + stops[2]
            }

        case 1:
            if nowSectionOfRoute == 0 {
                label.text = "第二段：" + stops[1] + "\n往 " + stops[2]
                label.accessibilityLabel = "第二段。" + stops[1] + "。往。" + stops[2]
            } else {
                label.text = ""
                label.accessibilityLabel = ""
            }

        default:
            break
        }
        
        headerView.addSubview(label)

        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            if nowSectionOfRoute == 0 {
                return cellCount[0]
            } else {
                return cellCount[1]
            }
        case 1:
            return cellCount[1]
        default:
            return cellCount[0]
        }
 
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 120
        } else {
            return 67
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "routeCellID", for: indexPath) as! RouteCell
            
            if nowSectionOfRoute == 0 {
                cell.busNameLabel.text = buses[indexPath.row]
                cell.timeLabel.text = "還有 " + times[indexPath.row] + " 分鐘進站"
            } else {
                cell.busNameLabel.text = busesS2[indexPath.row]
                cell.timeLabel.text = "還有 " + timesS2[indexPath.row] + " 分鐘進站"
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "routeCellID2", for: indexPath) as! Route2Cell

            cell.busName2Label.text = busesS2[indexPath.row]

            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if isUserArrive == false || indexPath.section != 0 {
            let alertController = UIAlertController(title: "提醒您，到達等候區時才可啟動預約功能", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "確認", style: .cancel) { (_) in }
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
            
        } else {
            var bookedBus = self.buses[indexPath.row]
            
            if self.nowSectionOfRoute != 0 {
                bookedBus = self.busesS2[indexPath.row]
            }
            
            let controller = UIAlertController(title: "是否要預約 " + bookedBus, message: nil, preferredStyle: .actionSheet)
            
            let action = UIAlertAction(title:"預約上車", style: .default) { (_) in
                                                    
                let bookedView = self.storyboard?.instantiateViewController(withIdentifier: "bookViewID") as! BookedRouteViewController
                
                bookedView.busSection = indexPath.section
                bookedView.transferOrEndStop = self.stops[1]
                if self.nowSectionOfRoute != 0 {
                    bookedView.busSection = indexPath.section + 1
                    bookedView.transferOrEndStop = self.stops[2]
                }
                
                bookedView.busName = bookedBus
                bookedView.busRow = indexPath.row
                bookedView.routeName = self.routeIndex[self.selectIndex]
                bookedView.startStop = self.stops[0]
                bookedView.endStop = self.stops[self.sectionCount - 1]
                bookedView.nowSectionOfRoute = self.nowSectionOfRoute
                bookedView.sectionCount = self.sectionCount
                Database.database().reference().child("isBook").setValue(1)
                bookedView.modalPresentationStyle = .fullScreen
                self.present(bookedView, animated: true, completion: nil)
                
            }
            controller.addAction(action)

            let cancelAction = UIAlertAction(title: "取消預約", style: .cancel){ (_) in
            }
            controller.addAction(cancelAction)

            present(controller, animated: true, completion: nil)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
