//
//  TakingBusNoNotifiViewController.swift
//  BusPlusA
//
//  Created by iui on 2020/2/1.
//  Copyright © 2020 Carolyn Yu. All rights reserved.
//

import UIKit
import FirebaseDatabase
import AudioToolbox

class TakingBusNoNotifiViewController: UIViewController {

    @IBOutlet weak var isBookLabel: UILabel!
    @IBOutlet weak var busNameLabel: UILabel!
    @IBOutlet weak var startStopLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var endStopLabel: UILabel!
    @IBOutlet weak var ticketCutView: UIView!
    
    @IBOutlet weak var countDownView: UIView!
    @IBOutlet weak var isArriveLabel: UILabel!
    @IBOutlet weak var isArriveStopLabel: UILabel!
    @IBOutlet weak var nextStopLabel: UILabel!
    @IBOutlet weak var nextStopNameLabel: UILabel!

    
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var endBtn: UIButton!
    
    var routeName = "route1"
    var busSection = 0
    var busRow = 0
    var startStop = "捷運南京復興站"
    var transferOrEndStop = "捷運松江南京站"
    var finalStop = "圓環"
    var busName = "南京幹線"
    
    var stops = ["南京敦化路口(小巨蛋)", "南京寧安街口", "南京三民路口", "南京公寓(捷運南京三民)", "南京舊宗路口", "潭美公園"]
    
    var currentBusStop = 0
    var currentBusStopName = "捷運南京復興站"
    var nowSectionOfRoute = 0
    var sectionCount = 1
    
    var stopCount = "6"
    
    var routeRef : DatabaseReference?
    var routeUpdateHandle : DatabaseHandle = 0
    
    var currentStopRef : DatabaseReference?
    var currentStopUpdateHandle : DatabaseHandle = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        nextStopLabel.accessibilityElementsHidden = true
        nextStopNameLabel.accessibilityElementsHidden = true

        isArriveLabel.accessibilityElementsHidden = true
        isArriveStopLabel.accessibilityElementsHidden = true
        countDownView.isAccessibilityElement = true
        countDownView.accessibilityLabel = "已到達。" + currentBusStopName + "。。下一站。" + stops[0]
        countDownView.accessibilityTraits = UIAccessibilityTraits.none
        
//        endBtn.addTarget(self, action: #selector(clickEndButton), for: .touchUpInside)
        
        // static
        busNameLabel.text = busName
        startStopLabel.text = startStop
        endStopLabel.text = transferOrEndStop
        isArriveLabel.text = "已到達"
        
        currentBusStopName = startStop
        isArriveStopLabel.text = currentBusStopName
        
        Database.database().reference().child("isBook").setValue(0)

        routeRef = Database.database().reference().child("bus-routes").child(routeName)
        currentStopRef = Database.database().reference().child("currentBusStop")
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
                    
                    
                    if curBStop > 0 {
                        self.currentBusStopName = self.stops[curBStop-1]
                    }
                    
                    self.isArriveStopLabel.text = self.currentBusStopName
                    
                    self.nextStopLabel.text = "下一站"
                    self.nextStopNameLabel.text = self.stops[curBStop]
                    
                    
                    self.countDownView.accessibilityLabel = "已抵達。" + self.currentBusStopName + "。。下一站。" + self.stops[curBStop]
                    
                    // add next stop to database
                    Database.database().reference().child("nextStop").setValue(self.stops[curBStop])
                    
                    if self.nowSectionOfRoute == 0 && self.sectionCount > 2 {
                        self.endBtn.addTarget(self, action: #selector(self.clickEndButtonToNext), for: .touchUpInside)
                    } else {
                        self.endBtn.addTarget(self, action: #selector(self.clickEndButton), for: .touchUpInside)
                    }
                    
                }
            })
            
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
    
    @objc func clickEndButton(){
        let alertController = UIAlertController(title: "是否結束搭乘", message: nil, preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: "是", style: .default) { (_) in
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            
            Database.database().reference().child("isBookGetOffBus").setValue(0)
            Database.database().reference().child("currentBusStop").setValue(0)
            Database.database().reference().child("sectionOfRoute").setValue(0)
            self.currentStopRef?.removeObserver(withHandle: self.currentStopUpdateHandle)
            Database.database().reference().child("currentBusStop").setValue(0)
            Database.database().reference().child("isUserArrive").setValue(0)
            Database.database().reference().child("isAtDestination").setValue(0)
        }
        alertController.addAction(acceptAction)
        
        let cancelAction = UIAlertAction(title: "否", style: .cancel) { (_) in }
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true) {}
    }
    
    @objc func clickEndButtonToNext() {
        let controller = UIAlertController(title: nil , message: nil, preferredStyle: .actionSheet)
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
        
        present(controller, animated: true, completion: nil)
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        routeRef!.removeObserver(withHandle: routeUpdateHandle)
        currentStopRef!.removeObserver(withHandle: currentStopUpdateHandle)
    }

}
