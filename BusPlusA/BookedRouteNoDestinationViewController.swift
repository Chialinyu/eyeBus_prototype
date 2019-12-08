//
//  BookedRouteNoDestinationViewController.swift
//  BusPlusA
//
//  Created by iui on 2019/12/8.
//  Copyright © 2019 Carolyn Yu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import AudioToolbox

class BookedRouteNoDestinationViewController: UIViewController {

    @IBOutlet weak var isBookLabel: UILabel!
    @IBOutlet weak var busNameLabel: UILabel!
    @IBOutlet weak var startStopLabel: UILabel!
    
    @IBOutlet weak var stillLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var minsLabel: UILabel!
    @IBOutlet weak var comingLabel: UILabel!
    
    @IBOutlet weak var ticketFullView: UIView!
    @IBOutlet weak var timeView: UIView!
    
    var routeName = "route2"
    var busSection = 0
    var busRow = 0
    var startStop = "南京敦化路口"

    var busName = "南京幹線"
    var busTime = "20"

    var nowSectionOfRoute = 0
    var sectionCount = 1
    
    var routeRef : DatabaseReference?
    var routeUpdateHandle : DatabaseHandle = 0
    
    var busArriveRef : DatabaseReference?
    var busArriveUpdateHandle : DatabaseHandle = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark
        } else {
            // Fallback on earlier versions
            // change status bar text color into white
        }
        
        isBookLabel.accessibilityElementsHidden = true
        busNameLabel.accessibilityElementsHidden = true
        startStopLabel.accessibilityElementsHidden = true
        
        ticketFullView.isAccessibilityElement = true
        ticketFullView.accessibilityLabel = "已預約。" + busName + "。" + startStop
        ticketFullView.accessibilityTraits = UIAccessibilityTraits.none
        
        stillLabel.accessibilityElementsHidden = true
        timeLabel.accessibilityElementsHidden = true
        minsLabel.accessibilityElementsHidden = true
        comingLabel.accessibilityElementsHidden = true
        
        timeView.isAccessibilityElement = true
        timeView.accessibilityLabel = "還有" + busTime + "分鐘進站"
        timeView.accessibilityTraits = UIAccessibilityTraits.none
        
        // static
        busNameLabel.text = busName
        startStopLabel.text = startStop
        comingLabel.text = ""
        
        timeLabel.text = busTime
        
        routeRef = Database.database().reference().child("bus-routes").child(routeName)
        busArriveRef = Database.database().reference().child("isBusArrive")
        
        routeUpdateHandle = routeRef!.observe(DataEventType.value, with: { (snapshot) in
            let retrievedDict = snapshot.value as! NSDictionary
            let busesArray = retrievedDict["buses"] as! NSArray
            let busesSection = busesArray[self.busSection] as! NSArray
            let bus = busesSection[self.busRow] as! NSDictionary
            
            self.busTime = bus["time"] as! String
            
            DispatchQueue.global().async(execute: {
                DispatchQueue.main.async {

                    self.stillLabel.text = "還有"
                    self.timeLabel.text = self.busTime
                    self.minsLabel.text = "分鐘進站"
                    self.comingLabel.text = ""
                    self.timeView.accessibilityLabel = "還有" + self.busTime + "分鐘進站"
                    
                    if Int(self.busTime) ?? 3 < 3 {
                        self.stillLabel.text = ""
                        self.timeLabel.text = ""
                        self.minsLabel.text = ""
                        self.comingLabel.text = "即將進站"
                        self.timeView.accessibilityLabel = "即將進站"
                        
                        // vibration haptic feedback
                        //1519 peek 1520 pop 1521 nope kSystemSoundID_Vibrate
                        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                        
                        // voiceover announce
                        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: "即將進站")
                        
                    } else if Int(self.busTime) ?? 3 >= 3 {
                        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: "還有" + self.busTime + "分鐘進站")
                        
                    }
                }
            })
        })
        
        busArriveUpdateHandle = busArriveRef!.observe(DataEventType.value, with: { (snapshot) in
            let isBusArrive = snapshot.value as? Bool
            if isBusArrive ?? false {
                let controller = UIAlertController(title: "是否已搭上 " + self.busName /*+ "往" + self.transferOrEndStop */ , message: nil, preferredStyle: .actionSheet)
                
                let action1 = UIAlertAction(title:"已上車", style: .default) { (_) in
                    
                    let alertController = UIAlertController(title: nil , message: "已確認上車，結束預約服務。", preferredStyle: .alert)
                    let acceptAction = UIAlertAction(title: "確認", style: .default) { (_) in
                        self.dismiss(animated: true, completion: nil)
                        Database.database().reference().child("isBook").setValue(0)
                        Database.database().reference().child("isBusArrive").setValue(0)
                        Database.database().reference().child("isBookGetOffBus").setValue(0)
                        
                        // if not turn on TakeOffAlert jump to next section bus list page
                        Database.database().reference().child("isUserArrive").setValue(0)
                        if self.sectionCount > 2 {
                            if self.nowSectionOfRoute == 0 {
                                Database.database().reference().child("sectionOfRoute").setValue(1)
                            } else {
                                Database.database().reference().child("sectionOfRoute").setValue(0)
                            }
                        }
                    }
                    alertController.addAction(acceptAction)
                    
                    self.present(alertController, animated: true) {}
                    
                }
                controller.addAction(action1)
                
                let action2 = UIAlertAction(title:"錯過公車", style: .default) {(_) in
                                        
                    let alertController = UIAlertController(title: "是否預約下一班" + self.busName, message: "還有" + self.busTime + "分鐘進站", preferredStyle: .alert)
                    let acceptAction = UIAlertAction(title: "是", style: .default) { (_) in
                        Database.database().reference().child("isBook").setValue(1)
                        Database.database().reference().child("isBusArrive").setValue(0)
                    }
                    alertController.addAction(acceptAction)

                    let cancelAction = UIAlertAction(title: "否", style: .cancel) { (_) in
                        self.dismiss(animated: true, completion: nil)
                        Database.database().reference().child("isBook").setValue(0)
                        Database.database().reference().child("isBusArrive").setValue(0)
                        Database.database().reference().child("isBookGetOffBus").setValue(0)
                        self.dismiss(animated: true, completion: nil)
                    }
                    alertController.addAction(cancelAction)

                    self.present(alertController, animated: true) {}
                }
                controller.addAction(action2)
                
                let cancelAction = UIAlertAction(title: "取消預約", style: .cancel){ (_) in
                    Database.database().reference().child("isBook").setValue(0)
                    Database.database().reference().child("isBusArrive").setValue(0)
                    Database.database().reference().child("isBookGetOffBus").setValue(0)
                    self.dismiss(animated: true, completion: nil)
                }
                controller.addAction(cancelAction)

                self.present(controller, animated: true, completion: nil)
            }
            
            
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeHandles()
    }
    
    func removeHandles(){
        routeRef!.removeObserver(withHandle: routeUpdateHandle)
        busArriveRef!.removeObserver(withHandle: busArriveUpdateHandle)
    }

    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            
            if shakeCount == 0 {
                shakeCount = 1
                timer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { (_) in
                    shakeCount = 0
                }
            } else if shakeCount == 1 {
                shakeCount = 0
                timer?.invalidate()
                
                let alertController = UIAlertController(title: "是否要取消預約", message: nil, preferredStyle: .alert)
                let acceptAction = UIAlertAction(title: "是", style: .default) { (_) in
                    self.dismiss(animated: true, completion: nil)
                    Database.database().reference().child("isBook").setValue(0)
                }
                alertController.addAction(acceptAction)
                
                let cancelAction = UIAlertAction(title: "否", style: .cancel) { (_) in }
                alertController.addAction(cancelAction)
                
                present(alertController, animated: true) {}
            }
            
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
