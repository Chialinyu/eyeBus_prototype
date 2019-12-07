//
//  DirectionsViewController.swift
//  BusPlusA
//
//  Created by iui on 2019/12/7.
//  Copyright © 2019 Carolyn Yu. All rights reserved.
//

import UIKit

class direction2Cell:UITableViewCell {
    @IBOutlet weak var transferStopLabel: UILabel!
    @IBOutlet weak var travelDuration2Label: UILabel!
}

class direction1Cell:UITableViewCell {
    @IBOutlet weak var travelDurationLabel: UILabel!
}

class DirectionsViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var urLocationTextField: UITextField!
    @IBOutlet weak var urForwardTextField: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var resultTableView: UITableView!
    
    var urLocation = ""
    var urForward = ""
    var status = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "規劃路線"
        
        urLocationTextField.delegate = self
        urForwardTextField.delegate = self
        
        resultTableView.delegate = self
        resultTableView.dataSource = self
        
        searchBtn.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        urLocation = urLocationTextField.text ?? ""
        urForward = urForwardTextField.text ?? ""

        urLocationTextField.resignFirstResponder()
        urForwardTextField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    @objc func clickButton() {
        
        urLocation = urLocationTextField.text ?? ""
        urForward = urForwardTextField.text ?? ""
                
        self.view.endEditing(true)
        urLocationTextField.resignFirstResponder()
        urForwardTextField.resignFirstResponder()
        
        
        
        if CFStringHasPrefix(urForward as CFString, "圓環" as CFString) || CFStringHasPrefix(urForward as CFString, "南京" as CFString) {
            status = 1
        } else if CFStringHasPrefix(urForward as CFString, "捷運" as CFString) || CFStringHasPrefix(urForward as CFString, "中山" as CFString) || CFStringHasPrefix(urForward as CFString, "志仁" as CFString) || CFStringHasPrefix(urForward as CFString, "高中" as CFString) {
            status = 2
        } else {
            status = 0
        }
        
        resultTableView.reloadData()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        let label = UILabel()
        label.frame = CGRect.init(x: 40, y: 20, width: 375-80, height: 24)
        label.numberOfLines = 0
        label.textColor = UIColor(rgb: 0xffffff)
        
        if status == 1 {
            label.text = "顯示搜尋結果共 2 筆"
        } else if status == 2 {
            label.text = "顯示搜尋結果共 1 筆"
        } else {
            label.text = ""
        }
        
        headerView.addSubview(label)

        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if status == 1 {
            return 2
        } else if status == 2 {
            return 1
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if status == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "result2CellID", for: indexPath) as! direction2Cell
                cell.transferStopLabel.text = "捷運松江南京站"
                cell.travelDuration2Label.text = "總交通時間：15分鐘"
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "result1CellID", for: indexPath) as! direction1Cell
                cell.travelDurationLabel.text = "總交通時間：25分鐘"
                return cell
            } else {
//                    return UITableViewCell()
                let cell = tableView.dequeueReusableCell(withIdentifier: "result1CellID", for: indexPath) as! direction1Cell
                return cell
            }
            
        } else if status == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "result1CellID", for: indexPath) as! direction1Cell
            cell.travelDurationLabel.text = "總交通時間：20分鐘"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "result1CellID", for: indexPath) as! direction1Cell
            return cell
//                return UITableViewCell()
        }
            
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if status == 1 {
            switch indexPath.row {
            case 0:
                return 196
            case 1:
                return 128
            default:
                return 196
            }
        } else {
            return 128
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if status == 0 {
            // do nothing fake cell
        } else if status == 1 {
            if indexPath.row == 0 {
                let routeView = storyboard?.instantiateViewController(withIdentifier: "favRouteContentID2") as! FavRoute2ViewController
                routeView.selectIndex = 0
                routeView.sectionCount = 3 // useless
                navigationController?.pushViewController(routeView, animated: true)
            } else {
                let routeView = storyboard?.instantiateViewController(withIdentifier: "favRouteContentID1") as! FavRouteViewController
                routeView.selectIndex = 2
                routeView.sectionCount = 2 // useless
                navigationController?.pushViewController(routeView, animated: true)
            }
        } else if status == 2 {
            let routeView = storyboard?.instantiateViewController(withIdentifier: "favRouteContentID1") as! FavRouteViewController
            routeView.selectIndex = 1
            routeView.sectionCount = 2 // useless
            navigationController?.pushViewController(routeView, animated: true)
        } else {
            
        }
    }
    


}
