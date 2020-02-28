//
//  TakingBusViewController.swift
//  BusPlusA
//
//  Created by iui on 2019/12/6.
//  Copyright © 2019 Carolyn Yu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import AudioToolbox
//import AVFoundation

var timer2: Timer?
var shakeCount2  = 0

class TakingBusViewController: UIViewController {
    @IBOutlet weak var isBookLabel: UILabel!
    @IBOutlet weak var busNameLabel: UILabel!
    @IBOutlet weak var startStopLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var endStopLabel: UILabel!
    @IBOutlet weak var ticketCutView: UIView!
    
    @IBOutlet weak var stillLabel: UILabel!
    @IBOutlet weak var countsLabel: UILabel!
    @IBOutlet weak var stopLabel: UILabel!
    @IBOutlet weak var nextStopLabel: UILabel!
    @IBOutlet weak var nextStopNameLabel: UILabel!
//    @IBOutlet weak var lineImg: UIImageView!
    @IBOutlet weak var comingLabel: UILabel!
    @IBOutlet weak var finalStopNameLabel: UILabel!
    @IBOutlet weak var countDownView: UIView!
    
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var endBtn: UIButton!
    
    var routeName = "route1"
    var busSection = 0
    var busRow = 0
    var startStop = "南京敦化站"
    var transferOrEndStop = "捷運松江南京站"
    var finalStop = "圓環"
    var busName = "南京幹線"
    
    var stops = ["南京敦化路口(小巨蛋)", "南京寧安街口", "南京三民路口", "南京公寓(捷運南京三民)", "南京舊宗路口", "潭美公園"]
    var currentBusStop = 0
    var nowSectionOfRoute = 0
    var sectionCount = 1
    
    var stopCount = "6"
    
    var routeRef : DatabaseReference?
    var routeUpdateHandle : DatabaseHandle = 0
    
    var currentStopRef : DatabaseReference?
    var currentStopUpdateHandle : DatabaseHandle = 0
    
    var isAtDestination = 0
    
    var isAtDestinationRef : DatabaseReference?
    var isAtDestinationUpdateHandle : DatabaseHandle = 0
    
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
        
        ticketCutView.isAccessibilityElement = true
        ticketCutView.accessibilityLabel = "正在搭乘。" + busName + "。" + startStop + "。往。" + transferOrEndStop
        ticketCutView.accessibilityTraits = UIAccessibilityTraits.none
        
        stillLabel.accessibilityElementsHidden = true
        countsLabel.accessibilityElementsHidden = true
        stopLabel.accessibilityElementsHidden = true
        nextStopLabel.accessibilityElementsHidden = true
        nextStopNameLabel.accessibilityElementsHidden = true
//        lineImg.accessibilityElementsHidden = true
        comingLabel.accessibilityElementsHidden = true
        finalStopNameLabel.accessibilityElementsHidden = true
        
        countDownView.isAccessibilityElement = true
        countDownView.accessibilityLabel = "還有" + stopCount + "站抵達。。下一站。" + stops[0]
        countDownView.accessibilityTraits = UIAccessibilityTraits.none
        
//        endBtn.accessibilityElementsHidden = true
//        endBtn.isEnabled = false
        
        // static
        busNameLabel.text = busName
        startStopLabel.text = startStop
        endStopLabel.text = transferOrEndStop
        comingLabel.text = ""
        finalStopNameLabel.text = ""
        
        countsLabel.text = stopCount
        
        Database.database().reference().child("isBook").setValue(0)

        routeRef = Database.database().reference().child("bus-routes").child(routeName)
        currentStopRef = Database.database().reference().child("currentBusStop")
        isAtDestinationRef = Database.database().reference().child("isAtDestination")
        
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
    
    @objc func clickEndButton(){
        let alertController = UIAlertController(title: "是否結束搭乘", message: nil, preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: "是", style: .default) { (_) in
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            
            Database.database().reference().child("isBookGetOffBus").setValue(0)
            Database.database().reference().child("currentBusStop").setValue(0)
            Database.database().reference().child("sectionOfRoute").setValue(0)
            
            Database.database().reference().child("isUserArrive").setValue(0)
            Database.database().reference().child("isAtDestination").setValue(0)
            
        }
        alertController.addAction(acceptAction)
        
        let cancelAction = UIAlertAction(title: "否", style: .cancel) { (_) in }
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true) {}
    }
    
//    @objc func clickEndButtonAskLike(){
//        let alertController = UIAlertController(title: "是否結束搭乘？", message: nil, preferredStyle: .alert)
//        let acceptAction = UIAlertAction(title: "是", style: .default) { (_) in
//
////            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
//
//            Database.database().reference().child("isBookGetOffBus").setValue(0)
//            Database.database().reference().child("currentBusStop").setValue(0)
//            Database.database().reference().child("sectionOfRoute").setValue(0)
//
//            Database.database().reference().child("isUserArrive").setValue(0)
//            Database.database().reference().child("isAtDestination").setValue(0)
//
//            let askLikeAlert = UIAlertController(title: "幫司機按個讚？", message: nil, preferredStyle: .alert)
//            let likeAction = UIAlertAction(title: "讚啦！", style: .default) {(_) in
//                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
//            }
//            askLikeAlert.addAction(likeAction)
//            let dislikeAction = UIAlertAction(title: "下次吧～", style: .default) { (_) in
//                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
//            }
//            askLikeAlert.addAction(dislikeAction)
//            self.present(askLikeAlert, animated: true) {}
//
//        }
//        alertController.addAction(acceptAction)
//
//        let cancelAction = UIAlertAction(title: "否", style: .cancel) { (_) in }
//        alertController.addAction(cancelAction)
//
//        present(alertController, animated: true) {}
//    }
    
    @objc func clickEndButtonAskLike(){
        let alertController = UIAlertController(title: "是否結束搭乘？", message: nil, preferredStyle: .actionSheet)
        let acceptAction = UIAlertAction(title: "是", style: .default) { (_) in
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(acceptAction)
    
        let likeAction = UIAlertAction(title: "是，並幫司機按個讚！", style: .default) { (_) in
            
            let likeAlert = UIAlertController(title: "登愣，已幫司機按讚～", message: nil, preferredStyle: .alert)
            self.present(likeAlert, animated: true)
            // only show n second
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when){
                alertController.dismiss(animated: true, completion: nil)
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            }
            
//            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(likeAction)
        
        let cancelAction = UIAlertAction(title: "否", style: .cancel) { (_) in }
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true) {}
    }
    
    @objc func clickEndButtonToNext(){
        toNextSection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            
    routeUpdateHandle = routeRef!.observe(DataEventType.value, with: { (snapshot) in
        let retrievedDict = snapshot.value as! NSDictionary
        let busesArray = retrievedDict["buses"] as! NSArray
        let busesSection = busesArray[self.busSection] as! NSArray
        let bus = busesSection[self.busRow] as! NSDictionary
        
        self.stops = (bus["stops"] as! NSArray) as! [String]
        
    })
        
    currentStopUpdateHandle = currentStopRef!.observe(DataEventType.value, with: { (snapshot) in
        let currentBusStops = snapshot.value as? Int
        self.currentBusStop = currentBusStops ?? self.currentBusStop
        
        DispatchQueue.global().async(execute: {
            DispatchQueue.main.async {
                
                self.stopCount = String((self.stops.count - self.currentBusStop) > 0 ? (self.stops.count - self.currentBusStop): 1)
                                    
                let curBStop = self.currentBusStop < self.stops.count  ? self.currentBusStop : self.stops.count - 1
                
                self.stillLabel.text = "還有"
                self.countsLabel.text = self.stopCount
                self.stopLabel.text = "站抵達"
                self.nextStopLabel.text = "下一站"
                self.nextStopNameLabel.text = self.stops[curBStop]
//                    self.lineImg.isHidden = false
                self.comingLabel.text = ""
                self.finalStopNameLabel.text = ""
                
                self.countDownView.accessibilityLabel = "還有。" + self.stopCount + " 站抵達。。下一站。" + self.stops[curBStop]
                
                // add next stop to database
                Database.database().reference().child("nextStop").setValue(self.stops[curBStop])
                
                if self.nowSectionOfRoute == 0 && self.sectionCount > 2 {
                    self.endBtn.addTarget(self, action: #selector(self.clickEndButtonToNext), for: .touchUpInside)
                } else {
                    
//                    self.endBtn.addTarget(self, action: #selector(self.clickEndButton), for: .touchUpInside)
                    self.endBtn.addTarget(self, action: #selector(self.clickEndButtonAskLike), for: .touchUpInside)
                    
                }
                
                if self.currentBusStop >= self.stops.count - 1 {
                    
                    self.stillLabel.text = ""
                    self.countsLabel.text = ""
                    self.stopLabel.text = ""
                    self.nextStopLabel.text = ""
                    self.nextStopNameLabel.text = ""
//                        self.lineImg.isHidden = true
                    self.comingLabel.text = "即將抵達"
                    self.finalStopNameLabel.text = self.transferOrEndStop
                    
                    self.countDownView.accessibilityLabel = "即將抵達。" + self.stops[curBStop]
                    
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
                    UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: "即將抵達。" + self.stops[curBStop] /* + " 站" */);
                    
                    // enable the end Btn
//                    self.endBtn.isEnabled = true
//                    self.endBtn.accessibilityElementsHidden = false
                    
//                    if self.nowSectionOfRoute == 0 && self.sectionCount > 2 {
//                        self.endBtn.addTarget(self, action: #selector(self.clickEndButtonToNext), for: .touchUpInside)
//                    } else {
//                        self.endBtn.addTarget(self, action: #selector(self.clickEndButton), for: .touchUpInside)
//                    }
                    
                } else if self.currentBusStop >= self.stops.count - 3 {
                    UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: "還有。" + self.stopCount + " 站抵達。。下一站。" + self.stops[curBStop])
                    self.countDownView.accessibilityLabel = "還有。" + self.stopCount + " 站抵達。。下一站。" + self.stops[curBStop]
                }
                
                
            }
        })
        
    })
        
    isAtDestinationUpdateHandle = isAtDestinationRef!.observe(DataEventType.value, with: { (snapshot) in
        let isAtDestination = snapshot.value as? Bool
        if isAtDestination ?? false {
            Database.database().reference().child("isBookGetOffBus").setValue(0)

            if self.nowSectionOfRoute == 0 && self.sectionCount > 2 {

                self.toNextSection()
                
//                let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//                let action1 = UIAlertAction(title:"繼續下一段旅程", style: .default) { (_) in
//
//                    Database.database().reference().child("sectionOfRoute").setValue(1)
//                    Database.database().reference().child("isAtDestination").setValue(0)
//                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
//                    // to next section ~
//                }
//                controller.addAction(action1)
//                let action2 = UIAlertAction(title:"結束搭乘", style: .default) { (_) in
//
//                    Database.database().reference().child("isBookGetOffBus").setValue(0)
//                    Database.database().reference().child("currentBusStop").setValue(0)
//                    Database.database().reference().child("sectionOfRoute").setValue(0)
//                    self.currentStopRef?.removeObserver(withHandle: self.currentStopUpdateHandle)
//                    Database.database().reference().child("currentBusStop").setValue(0)
//                    Database.database().reference().child("isUserArrive").setValue(0)
//                    Database.database().reference().child("isAtDestination").setValue(0)
//                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
//                }
//                controller.addAction(action2)
//
//                self.present(controller, animated: true, completion: nil)

            } else {
                let controller = UIAlertController(title: nil , message: nil, preferredStyle: .actionSheet)

                let cancelAction = UIAlertAction(title: "已抵達 " + self.transferOrEndStop + "，結束搭乘", style: .cancel){ (_) in

                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)

                    Database.database().reference().child("isBookGetOffBus").setValue(0)
                    Database.database().reference().child("sectionOfRoute").setValue(0)
                    self.currentStopRef?.removeObserver(withHandle: self.currentStopUpdateHandle)
                    Database.database().reference().child("currentBusStop").setValue(0)
                    Database.database().reference().child("isUserArrive").setValue(0)
                    Database.database().reference().child("isAtDestination").setValue(0)
                }
                controller.addAction(cancelAction)
                self.present(controller, animated: true, completion: nil)
                
                // auto fade out after 120 second
                let when = DispatchTime.now() + 120
                DispatchQueue.main.asyncAfter(deadline: when){
                    controller.dismiss(animated: true, completion: nil)
                    
                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)

                    Database.database().reference().child("isBookGetOffBus").setValue(0)
                    Database.database().reference().child("sectionOfRoute").setValue(0)
                    self.currentStopRef?.removeObserver(withHandle: self.currentStopUpdateHandle)
                    Database.database().reference().child("currentBusStop").setValue(0)
                    Database.database().reference().child("isUserArrive").setValue(0)
                    Database.database().reference().child("isAtDestination").setValue(0)
                }
                
            }
        }
        
    })
        
    }
    
    func toNextSection(){
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title:"繼續下一段旅程", style: .default) { (_) in

            Database.database().reference().child("sectionOfRoute").setValue(1)
            Database.database().reference().child("isAtDestination").setValue(0)
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            // to next section ~
        }
        controller.addAction(action1)
        let action2 = UIAlertAction(title:"結束搭乘", style: .default) { (_) in

            Database.database().reference().child("isBookGetOffBus").setValue(0)
            Database.database().reference().child("currentBusStop").setValue(0)
            Database.database().reference().child("sectionOfRoute").setValue(0)
            self.currentStopRef?.removeObserver(withHandle: self.currentStopUpdateHandle)
            Database.database().reference().child("currentBusStop").setValue(0)
            Database.database().reference().child("isUserArrive").setValue(0)
            Database.database().reference().child("isAtDestination").setValue(0)
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
        controller.addAction(action2)

        self.present(controller, animated: true, completion: nil)
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        routeRef!.removeObserver(withHandle: routeUpdateHandle)
        currentStopRef!.removeObserver(withHandle: currentStopUpdateHandle)
    }
        

    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {

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
