//
//  FavRouteViewController.swift
//  BusPlusA
//
//  Created by iui on 2019/12/8.
//  Copyright © 2019 Carolyn Yu. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FavRouteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var startStopLabel: UILabel!
    @IBOutlet weak var endStopLabel: UILabel!
    @IBOutlet weak var addFavImg: UIImageView!
    @IBOutlet weak var addFavBtn: UIButton!
    @IBOutlet weak var routeTableView: UITableView!
    
    var routeIndex = ["route1", "route2", "route3"]
    var selectIndex = 1
    var sectionCount = 2 // = stop counts
    var stops = ["南京敦化路口", "捷運中山站"]
    var buses = ["棕 9 南京幹線", "4 6", "2 8 2"]
    var times = ["10", "20", "20"]
    var cellCount = [3, 3]
    var isUserArrive = false
    var nowSectionOfRoute = 0 // 紀錄現在在第幾度段旅程
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "直達路線"
        
        routeTableView.delegate = self
        routeTableView.dataSource = self
        
        addFavBtn.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
        
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
            
            let isUserArriveRef = Database.database().reference().child("isUserArrive")
            
            isUserArriveRef.observe(DataEventType.value, with: { (snapshot) in
                let retrievedDict = snapshot.value as? Bool
                self.isUserArrive = retrievedDict ?? self.isUserArrive
            })
            
            self.routeTableView.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
        
        label.text = stops[0] + "\n往 " + stops[1]
        label.accessibilityLabel = stops[0] + "。往。" + stops[1]
        
        headerView.addSubview(label)

        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellCount[0]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeCellID", for: indexPath) as! RouteCell
        
        cell.busNameLabel.text = buses[indexPath.row]
        cell.timeLabel.text = "還有 " + times[indexPath.row] + " 分鐘進站"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if isUserArrive == false || indexPath.section != 0 {
            let alertController = UIAlertController(title: "提醒您，到達等候區時才可啟動預約功能", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "確認", style: .cancel) { (_) in }
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
            
        } else {
            let bookedBus = self.buses[indexPath.row]
            
            let controller = UIAlertController(title: "是否要預約 " + bookedBus, message: nil, preferredStyle: .actionSheet)
            
            let action = UIAlertAction(title:"預約上車", style: .default) { (_) in
                                                    
                let bookedView = self.storyboard?.instantiateViewController(withIdentifier: "bookViewID") as! BookedRouteViewController
                
                bookedView.busSection = indexPath.section
                bookedView.transferOrEndStop = self.stops[1]
                
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
    
    @objc func clickButton() {
        
        let alertController = UIAlertController(title: "已加入常用路線", message: nil, preferredStyle: .alert)
//        let acceptAction = UIAlertAction(title: "確認", style: .default) { (_) in
//            self.dismiss(animated: true, completion: nil)
//        }
//        alertController.addAction(acceptAction)
        present(alertController, animated: true) {}
        // only show n second
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when){
          alertController.dismiss(animated: true, completion: nil)
        }
        
        addFavBtn.isEnabled =  false
        addFavBtn.setTitle("已加入常用路線", for: .normal)
        addFavImg.image = UIImage(named: "add_fav_btn_gray")
        
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
