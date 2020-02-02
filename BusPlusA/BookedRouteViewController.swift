//
//  BookedRouteViewController.swift
//  BusPlusA
//
//  Created by iui on 2019/12/6.
//  Copyright © 2019 Carolyn Yu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import AudioToolbox
//import AVFoundation

var timer: Timer?
var shakeCount  = 0


class BookedRouteViewController: UIViewController {
    
    @IBOutlet weak var isBookLabel: UILabel!
    @IBOutlet weak var busNameLabel: UILabel!
    @IBOutlet weak var startStopLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var endStopLabel: UILabel!
    
    @IBOutlet weak var stillLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var minsLabel: UILabel!
    @IBOutlet weak var comingLabel: UILabel!
    
    @IBOutlet weak var ticketFullView: UIView!
    @IBOutlet weak var timeView: UIView!
    
    @IBOutlet weak var isOnBoardBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    
    
    var routeName = "route1"
    var busSection = 0
    var busRow = 0
    var transferOrEndStop = "圓環"
    var startStop = "南京敦化路口"
    var endStop = "圓環"

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
        toLabel.accessibilityElementsHidden = true
        endStopLabel.accessibilityElementsHidden = true
        
        infoBtn.accessibilityLabel = "公車資訊"
        infoBtn.addTarget(self, action: #selector(clickInfoButton), for: .touchUpInside)
        
        ticketFullView.isAccessibilityElement = true
        ticketFullView.accessibilityLabel = "已預約。" + busName + "。" + startStop + "。往。" + transferOrEndStop
        ticketFullView.accessibilityTraits = UIAccessibilityTraits.none
        
        stillLabel.accessibilityElementsHidden = true
        timeLabel.accessibilityElementsHidden = true
        minsLabel.accessibilityElementsHidden = true
        comingLabel.accessibilityElementsHidden = true
        
        timeView.isAccessibilityElement = true
        timeView.accessibilityLabel = "還有" + busTime + "分鐘進站"
        timeView.accessibilityTraits = UIAccessibilityTraits.none
        
        isOnBoardBtn.accessibilityElementsHidden = true
        isOnBoardBtn.addTarget(self, action: #selector(clickOnBoardButton), for: .touchUpInside)
        
        cancelBtn.addTarget(self, action: #selector(clickCancelButton), for: .touchUpInside)
        
        // static
        busNameLabel.text = busName
        startStopLabel.text = startStop
        endStopLabel.text = transferOrEndStop
        comingLabel.text = ""
        
        timeLabel.text = busTime
        
        isOnBoardBtn.isEnabled =  false
        
        routeRef = Database.database().reference().child("bus-routes").child(routeName)
        busArriveRef = Database.database().reference().child("isBusArrive")
        
        routeUpdateHandle = routeRef!.observe(DataEventType.value, with: { (snapshot) in
            let retrievedDict = snapshot.value as! NSDictionary
            let busesArray = retrievedDict["buses"] as! NSArray
            let busesSection = busesArray[self.busSection] as! NSArray
            let bus = busesSection[self.busRow] as! NSDictionary
            
//            self.busName = bus["name"] as! String
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
                        
                        // to play sound
                        // 1304 alarm.caf from iOSSystemSoundsLibrary
                        AudioServicesPlayAlertSound(SystemSoundID(1304))
                        
                        // vibration haptic feedback
                        //1519 peek 1520 pop 1521 nope kSystemSoundID_Vibrate
                        for _ in 1...2 {
                            AudioServicesPlayAlertSound(UInt32(kSystemSoundID_Vibrate))
                            sleep(1)
                        }
                        
                        // voiceover announce
                        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: "即將進站")
                        
                        
                        // turn on the onBoard btn
                        self.isOnBoardBtn.setBackgroundImage(UIImage(named: "ticket_btn_yellow"), for: UIControl.State.normal)
                        self.isOnBoardBtn.setTitleColor(.black, for: .normal)
                        self.isOnBoardBtn.isEnabled = true
                        self.isOnBoardBtn.accessibilityElementsHidden = false
                        
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
                    
                    self.onboardConfirm()
                    
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
    
    @objc func clickInfoButton() {
        let busPlate = "車牌：0 8 0 - F U, \n"
        let busType = "公車種類：低底盤公車, \n"
        let busDriver = "駕駛員：王永順"
        let alertController = UIAlertController(title: "\(busPlate) \(busType) \(busDriver)", message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "確認", style: .cancel) { (_) in }
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
        
        // only show n second
        let when = DispatchTime.now() + 15
        DispatchQueue.main.asyncAfter(deadline: when){
          alertController.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func clickOnBoardButton() {
        self.onboardConfirm()
    }
    
    @objc func clickCancelButton() {
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeHandles()
    }
    
    func removeHandles(){
        routeRef!.removeObserver(withHandle: routeUpdateHandle)
        busArriveRef!.removeObserver(withHandle: busArriveUpdateHandle)
    }

    func onboardConfirm(){
        let alertController = UIAlertController(title: nil , message: "已確認上車，是否需要開啟下車提醒", preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: "需要", style: .default) { (_) in
                                    
            Database.database().reference().child("isBook").setValue(0)
            Database.database().reference().child("isBusArrive").setValue(0)
            Database.database().reference().child("isBookGetOffBus").setValue(1)
            
            let takeBusView = self.storyboard?.instantiateViewController(withIdentifier: "takeBusID") as! TakingBusViewController
            takeBusView.modalPresentationStyle = .fullScreen
            takeBusView.routeName = self.routeName
            takeBusView.busSection = self.busSection
            takeBusView.busRow = self.busRow
            takeBusView.busName = self.busName
            takeBusView.startStop = self.startStop
            takeBusView.transferOrEndStop = self.transferOrEndStop
            takeBusView.finalStop = self.endStop
            
            
            takeBusView.nowSectionOfRoute = self.nowSectionOfRoute
            takeBusView.sectionCount = self.sectionCount
            
            self.present(takeBusView, animated: true, completion: nil)
            
        }
        alertController.addAction(acceptAction)
        
        let cancelAction = UIAlertAction(title: "不需要", style: .default) { (_) in
            
            Database.database().reference().child("isBook").setValue(0)
            Database.database().reference().child("isBusArrive").setValue(0)
            Database.database().reference().child("isBookGetOffBus").setValue(1)
            
            let takeBusView = self.storyboard?.instantiateViewController(withIdentifier: "takeBusNoNotifiID") as! TakingBusNoNotifiViewController
            takeBusView.modalPresentationStyle = .fullScreen
            takeBusView.routeName = self.routeName
            takeBusView.busSection = self.busSection
            takeBusView.busRow = self.busRow
            takeBusView.busName = self.busName
            takeBusView.startStop = self.startStop
            takeBusView.transferOrEndStop = self.transferOrEndStop
            takeBusView.finalStop = self.endStop
            
            takeBusView.nowSectionOfRoute = self.nowSectionOfRoute
            takeBusView.sectionCount = self.sectionCount
            
            self.present(takeBusView, animated: true, completion: nil)
            
//            self.dismiss(animated: true, completion: nil)
//            Database.database().reference().child("isBook").setValue(0)
//            Database.database().reference().child("isBusArrive").setValue(0)
//            Database.database().reference().child("isBookGetOffBus").setValue(0)
//
//            // if not turn on TakeOffAlert jump to next section bus list page
//            Database.database().reference().child("isUserArrive").setValue(0)
//            if self.sectionCount > 2 {
//                if self.nowSectionOfRoute == 0 {
//                    Database.database().reference().child("sectionOfRoute").setValue(1)
//                } else {
//                    Database.database().reference().child("sectionOfRoute").setValue(0)
//                }
//            }
            
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true) {}
    }
    


    

}
