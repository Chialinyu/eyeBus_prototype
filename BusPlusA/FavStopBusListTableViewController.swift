//
//  FavStopBusListTableViewController.swift
//  BusPlusA
//
//  Created by iui on 2020/2/2.
//  Copyright © 2020 Carolyn Yu. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FavStopBusListTableViewController: UITableViewController {

    var busStop = "捷運南京復興站"
    
    var isUserArrive = false
    
    let busList_name = ["棕 9 南京幹線","2 8 2", "2 6 6 承德幹線"]
    
    let busList_direction = ["南港高工", "動物園", "捷運市政府站"]
    
    let busList_time = ["9", "13", "4"]
    
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "favStopBusCellID", for: indexPath) as! StopNearbyBusListCell

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
    //            cell.nbStopBusImg.image = UIImage(named: "nbStop_lightBlue")
                cell.nbStopBusImg.image = UIImage(named: "nbStop_yellow")
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
        
        let controller = UIAlertController(title: "是否要預約 " + bookedBus, message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title:"預約上車", style: .default) { (_) in
            
            if self.isUserArrive == false {
                let alertController = UIAlertController(title: "提醒您，到達等候區時才可啟動預約功能", message: nil, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "確認", style: .cancel) { (_) in }
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true)
            } else if Int(self.busList_time[indexPath.row]) ?? 0 == 0 {
                let alertController = UIAlertController(title: "尚未發車，請預約其他公車", message: nil, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "確認", style: .cancel) { (_) in }
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true)
            } else if Int(self.busList_time[indexPath.row]) ?? 0 == -1 {
                let alertController = UIAlertController(title: "末班駛離，請預約其他公車", message: nil, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "確認", style: .cancel) { (_) in }
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true)
            } else if Int(self.busList_time[indexPath.row]) ?? 0 < 3 {
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
                self.present(alertController, animated: true)
            } else if Int(self.busList_time[indexPath.row]) ?? 0 < 6 {
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
                self.present(alertController, animated: true)
            } else {
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
            
        }
        controller.addAction(action)

        
        let cancelAction = UIAlertAction(title: "取消預約", style: .cancel){ (_) in
        }
        controller.addAction(cancelAction)

        present(controller, animated: true, completion: nil)
    }
}
