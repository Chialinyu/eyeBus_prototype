//
//  BookedRouteViewController.swift
//  BusPlusA
//
//  Created by iui on 2019/12/6.
//  Copyright © 2019 Carolyn Yu. All rights reserved.
//

import UIKit

class BookedRouteViewController: UIViewController {
    @IBOutlet weak var busNameLabel: UILabel!
    @IBOutlet weak var startStopLabel: UILabel!
    @IBOutlet weak var endStopLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    var routeName = "route1"
    var busSection = 0
    var busRow = 0
    var transferOrEndStop = "圓環"
    var finalStop = "圓環"

    var busName = "南京幹線"
    var busTime = "6T"

    var nowSectionOfRoute = 0
    var sectionCount = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark
        } else {
            // Fallback on earlier versions
            // change status bar text color into white
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
