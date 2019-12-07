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
    @IBOutlet weak var lineImg: UIImageView!
    @IBOutlet weak var comingLabel: UILabel!
    @IBOutlet weak var finalStopNameLabel: UILabel!
    @IBOutlet weak var countDownView: UIView!
    
    var routeName = "route1"
    var busSection = 0
    var busRow = 0
    var startStop = "南京敦化站"
    var transferOrEndStop = "捷運松江南京站"
    var finalStop = "圓環"
    var busName = "南京幹線"
    
    var stops = ["捷運南京復興站", "南京龍江路口", "南京建國路口", "捷運松江南京站", "南京吉林路口", "南京林森路口", "捷運中山站(志仁高中)", "後車站", "圓環(重慶)", "圓環(南京)"]
    var currentBusStop = 0
    var nowSectionOfRoute = 0
    var sectionCount = 1
    
    var stopCount = "10"
    
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
        
        ticketCutView.isAccessibilityElement = true
        ticketCutView.accessibilityLabel = "已預約。" + busName + "。" + startStop + "。往。" + transferOrEndStop
        ticketCutView.accessibilityTraits = UIAccessibilityTraits.none
        
        stillLabel.accessibilityElementsHidden = true
        countsLabel.accessibilityElementsHidden = true
        stopLabel.accessibilityElementsHidden = true
        nextStopLabel.accessibilityElementsHidden = true
        nextStopNameLabel.accessibilityElementsHidden = true
        lineImg.accessibilityElementsHidden = true
        comingLabel.accessibilityElementsHidden = true
        finalStopNameLabel.accessibilityElementsHidden = true
        
        countDownView.isAccessibilityElement = true
        countDownView.accessibilityLabel = "還有" + stopCount + "站抵達。。下一站。" + stops[0]
        countDownView.accessibilityTraits = UIAccessibilityTraits.none
        
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
                    self.lineImg.isHidden = false
                    self.comingLabel.text = ""
                    self.finalStopNameLabel.text = ""
                    
                    self.countDownView.accessibilityLabel = "還有\n" + self.stopCount + " 站抵達。。下一站。" + self.stops[curBStop]
                    
                    // add next stop to database
                    Database.database().reference().child("nextStop").setValue(self.stops[curBStop])
                    
                    if self.currentBusStop >= self.stops.count - 1 {
                        
                        self.stillLabel.text = ""
                        self.countsLabel.text = ""
                        self.stopLabel.text = ""
                        self.nextStopLabel.text = ""
                        self.nextStopNameLabel.text = ""
                        self.lineImg.isHidden = true
                        self.comingLabel.text = "即將抵達"
                        self.finalStopNameLabel.text = self.transferOrEndStop
                        
                        self.countDownView.accessibilityLabel = "即將抵達。" + self.stops[curBStop]
                        
                        
                        // vibration haptic feedback
                        //1519 peek 1520 pop 1521 nope kSystemSoundID_Vibrate
                        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                        
                        // voiceover announce
                        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: "即將抵達。" + self.stops[curBStop] /* + " 站" */);
                    } else if self.currentBusStop >= self.stops.count - 3 {
                        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: "還有\n" + self.stopCount + " 站抵達。。下一站。" + self.stops[curBStop]);
                    }
                }
            })
            
        })
            
        isAtDestinationUpdateHandle = isAtDestinationRef!.observe(DataEventType.value, with: { (snapshot) in
            let isAtDestination = snapshot.value as? Bool
            if isAtDestination ?? false {
                Database.database().reference().child("isBookGetOffBus").setValue(0)

                if self.nowSectionOfRoute == 0 && self.sectionCount > 2 {

                    let controller = UIAlertController(title: "已抵達 " + self.transferOrEndStop /* + " 站" */, message: nil, preferredStyle: .actionSheet)
                    let action1 = UIAlertAction(title:"預約下一段路線", style: .default) { (_) in

                        Database.database().reference().child("sectionOfRoute").setValue(1)
                        Database.database().reference().child("isAtDestination").setValue(0)
                        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)

                        // to next section ~

                    }
                    controller.addAction(action1)

                    self.present(controller, animated: true, completion: nil)

                } else {
                    let controller = UIAlertController(title: "已抵達 " + self.transferOrEndStop /* + " 站" */ , message: nil, preferredStyle: .actionSheet)

                    let cancelAction = UIAlertAction(title: "結束搭乘", style: .cancel){ (_) in

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
                }
            }
            
        })
            
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            routeRef!.removeObserver(withHandle: routeUpdateHandle)
            currentStopRef!.removeObserver(withHandle: currentStopUpdateHandle)
        }
        

        override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
            if motion == .motionShake {

                if shakeCount2 == 0 {
                    shakeCount2 = 1
                    timer2 = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { (_) in
                        shakeCount2 = 0
                    }
                } else if shakeCount2 == 1 {
                    shakeCount2 = 0
                    timer2?.invalidate()
                    
                    let alertController = UIAlertController(title: "是否取消預約", message: nil, preferredStyle: .alert)
                    let acceptAction = UIAlertAction(title: "是", style: .default) { (_) in
                        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                        
                        Database.database().reference().child("isBookGetOffBus").setValue(0)
                        Database.database().reference().child("currentBusStop").setValue(0)
                        Database.database().reference().child("sectionOfRoute").setValue(0)
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
