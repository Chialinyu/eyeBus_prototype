//
//  StopsNearbyBusListTableViewController.swift
//  BusPlusA
//
//  Created by iui on 2019/12/8.
//  Copyright © 2019 Carolyn Yu. All rights reserved.
//

import UIKit
import FirebaseDatabase

class StopNearbyBusListCell:UITableViewCell {
    @IBOutlet weak var nbStopBusImg: UIImageView!
    @IBOutlet weak var nbStopBusNameLabel: UILabel!
    @IBOutlet weak var nbStopBusDirectionLabel: UILabel!
    @IBOutlet weak var nbStopBusTimeLabel: UILabel!
    @IBOutlet weak var nbStopBusBookLabel: UILabel!
}

class StopsNearbyBusListTableViewController: UITableViewController {

    let busList_name = ["3 3", "3 3", "4 6", "4 6", "2 6 2 區", "2 6 2 區", "2 6 6 承德幹線", "2 6 6 承德幹線", "2 8 2 副", "2 8 2 副", "3 0 6 區", "3 0 6 區", "棕 9 南京幹線", "棕 9 南京幹線", "紅 25", "紅 25"]
    let busList_direction = ["大直美麗華", "永春高中", "大直美麗華", "松德站", "民生社區", "中和", "捷運市政府站", "新北投", "圓環", "動物園", "台北橋", "舊莊", "圓環", "大直美麗華", "捷運北門站", "南港"]
    let busList_time = ["9", "13", "0", "1", "4", "15", "8", "1", "20", "5", "11", "-1", "6", "1", "13", "7"]
    // -1:末班駛離(灰) 0: 未發車(灰) 1~2: 進站中(黃) 3~5:時間(淺藍) 5+:時間(藍)
    
    var busStop = "南京敦化路口(小巨蛋)"
    var isUserArrive = false
        
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = busStop
        
        let isUserArriveRef = Database.database().reference().child("isUserArrive")
        
        isUserArriveRef.observe(DataEventType.value, with: { (snapshot) in
            let retrievedDict = snapshot.value as? Bool
            self.isUserArrive = retrievedDict ?? self.isUserArrive
        })
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return busList_name.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 158
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stopNearbyBusCellID", for: indexPath) as! StopNearbyBusListCell

        // static
        cell.nbStopBusNameLabel.text = busList_name[indexPath.row]
        cell.nbStopBusDirectionLabel.text = "往 " + busList_direction[indexPath.row]
        
        // float
        cell.nbStopBusImg.image = UIImage(named: "nbStop_blue")
        cell.nbStopBusTimeLabel.text = busList_time[indexPath.row] + " 分鐘進站"
        cell.nbStopBusBookLabel.text = "預約"
        cell.nbStopBusNameLabel.textColor = UIColor(rgb: 0xffffff)
        cell.nbStopBusDirectionLabel.textColor = UIColor(rgb: 0xffffff)
        cell.nbStopBusTimeLabel.textColor = UIColor(rgb: 0xffffff)
        cell.nbStopBusBookLabel.textColor = UIColor(rgb: 0xffffff)
                
        if Int(busList_time[indexPath.row]) ?? 0 == 0 {
            cell.nbStopBusImg.image = UIImage(named: "nbStop_gray")
            cell.nbStopBusTimeLabel.text = "未發車"
            cell.nbStopBusBookLabel.text = ""
        } else if Int(busList_time[indexPath.row]) ?? 0 == -1 {
            cell.nbStopBusImg.image = UIImage(named: "nbStop_gray")
            cell.nbStopBusTimeLabel.text = "末班駛離"
            cell.nbStopBusBookLabel.text = ""
        } else if Int(busList_time[indexPath.row]) ?? 0 < 3 {
            cell.nbStopBusImg.image = UIImage(named: "nbStop_yellow")
            cell.nbStopBusTimeLabel.text = "進站中"
            cell.nbStopBusBookLabel.text = ""
            cell.nbStopBusNameLabel.textColor = UIColor(rgb: 0x000000)
            cell.nbStopBusDirectionLabel.textColor = UIColor(rgb: 0x000000)
            cell.nbStopBusTimeLabel.textColor = UIColor(rgb: 0x000000)
        } else if Int(busList_time[indexPath.row]) ?? 0 < 6 {
            cell.nbStopBusImg.image = UIImage(named: "nbStop_lightBlue")
            cell.nbStopBusTimeLabel.text = busList_time[indexPath.row] + " 分鐘進站"
            cell.nbStopBusBookLabel.text = ""
            cell.nbStopBusNameLabel.textColor = UIColor(rgb: 0x000000)
            cell.nbStopBusDirectionLabel.textColor = UIColor(rgb: 0x000000)
            cell.nbStopBusTimeLabel.textColor = UIColor(rgb: 0x000000)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    let bookedBus = busList_name[indexPath.row]
        
        if isUserArrive == false {
            let alertController = UIAlertController(title: "預約失敗，到達等候區時可啟動預約功能", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "確認", style: .cancel) { (_) in }
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
        } else if Int(busList_time[indexPath.row]) ?? 0 == 0 {
            let alertController = UIAlertController(title: "尚未發車，請預約其他公車", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "確認", style: .cancel) { (_) in }
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
        } else if Int(busList_time[indexPath.row]) ?? 0 == -1 {
            let alertController = UIAlertController(title: "末班駛離，請預約其他公車", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "確認", style: .cancel) { (_) in }
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
        } else if Int(busList_time[indexPath.row]) ?? 0 < 3 {
            let alertController = UIAlertController(title: "公車進站中無法預約，是否要預約下一班 " + bookedBus + " 還有 15 分鐘進站", message: nil, preferredStyle: .alert)
            let acceptAction = UIAlertAction(title: "是", style: .default) { (_) in
                let bookedView = self.storyboard?.instantiateViewController(withIdentifier: "bookNoDestinationViewID") as! BookedRouteNoDestinationViewController
                
                bookedView.busSection = 0
                bookedView.busName = bookedBus
                bookedView.busRow = 0
                bookedView.routeName = "route2"
                bookedView.startStop = self.busStop
                bookedView.nowSectionOfRoute = 0
                bookedView.sectionCount = 2
                Database.database().reference().child("isBook").setValue(1)
                bookedView.modalPresentationStyle = .fullScreen
                self.present(bookedView, animated: true, completion: nil)
            }
            alertController.addAction(acceptAction)
            
            let cancelAction = UIAlertAction(title: "否", style: .cancel) { (_) in
            }
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
        } else if Int(busList_time[indexPath.row]) ?? 0 < 6 {
            let alertController = UIAlertController(title: "將在5分鐘內進站的公車無法預約，是否要預約下一班 " + bookedBus + " 還有 15 分鐘進站", message: nil, preferredStyle: .alert)
            let acceptAction = UIAlertAction(title: "是", style: .default) { (_) in
            let bookedView = self.storyboard?.instantiateViewController(withIdentifier: "bookNoDestinationViewID") as! BookedRouteNoDestinationViewController
                
                bookedView.busSection = 0
                bookedView.busName = bookedBus
                bookedView.busRow = 0
                bookedView.routeName = "route2"
                bookedView.startStop = self.busStop
                bookedView.nowSectionOfRoute = 0
                bookedView.sectionCount = 2
                Database.database().reference().child("isBook").setValue(1)
                bookedView.modalPresentationStyle = .fullScreen
                self.present(bookedView, animated: true, completion: nil)
                
            }
            alertController.addAction(acceptAction)
            
            let cancelAction = UIAlertAction(title: "否", style: .cancel) { (_) in
            }
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
        } else {
            
            let controller = UIAlertController(title: "是否要預約 " + bookedBus, message: nil, preferredStyle: .actionSheet)
            let action = UIAlertAction(title:"預約上車", style: .default) { (_) in
                                                    
                let bookedView = self.storyboard?.instantiateViewController(withIdentifier: "bookNoDestinationViewID") as! BookedRouteNoDestinationViewController
                
                bookedView.busSection = 0
                bookedView.busName = bookedBus
                bookedView.busRow = 0
                bookedView.routeName = "route2"
                bookedView.startStop = self.busStop
                bookedView.nowSectionOfRoute = 0
                bookedView.sectionCount = 2
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
    
}
