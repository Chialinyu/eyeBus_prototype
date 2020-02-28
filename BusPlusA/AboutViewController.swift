//
//  AboutViewController.swift
//  BusPlusA
//
//  Created by iui on 2019/12/6.
//  Copyright © 2019 Carolyn Yu. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    @IBOutlet weak var nowLabel: UILabel!
    @IBOutlet weak var nextLabel: UILabel!
    @IBOutlet weak var nowFuncLabel: UILabel!
    @IBOutlet weak var changeFuncLabel: UILabel!
    @IBOutlet weak var changeBtn: UIButton!
    @IBOutlet weak var contextView: UITextView!
    
    var status = 0
    
    var funcTitle = ["功能介紹", "預約流程介紹"]
    
    var content = [ "微笑公車是專為視覺障礙者設計的公車動態及預約App，除可用於日常獲取公車動態資訊外，也可在候車期間發送預約乘車需求。\n\n此App功能首頁有六種方式可以預約公車，依序為常用路線、常用站牌、常用公車、規劃路線、附近站牌以及搜尋公車，以下簡要說明功能：\n\n1. 常用路線 \n您可以從規劃路線功能儲存常搭乘的起迄公車站點，選擇公車號碼開始預約。\n\n2. 常用站牌 \n您可從附近站牌或搜尋公車功能儲存特定公車號碼的起點站牌，預約更快速。 \n\n3. 常用公車 \n您可從搜尋公車功能儲存特定公車號碼，選擇起點站牌後開始預約。 \n\n4. 規劃路線 \n您可以輸入起迄公車站點，搜尋後可依序查看最佳搭乘路線，選擇公車號碼並開始預約。 \n\n5. 附近站牌 \n您可查看所在位置附近的公車站牌，選擇公車站牌作為起站，即可查看行經此站之公車，選擇公車號碼便開始預約。 \n\n6. 搜尋公車 \n您可以輸入公車號碼，查看該公車行經的公車站牌以及公車動態。選擇起站後可開始預約。", "公車預約服務係為公部門結合客運公司等民間單位協力完成。您可透過此App發送預約資訊，由司機提早接收乘車需求，並停靠於該公車站之指定候車區。為維持服務穩定順暢，請用戶遵守公車預約之流程：\n\n1. 請於使用App期間開啟GPS定位。 \n\n2. 請站立於公車站亭之指定候車區，方可送出從該站上車之預約需求。 \n\n3. 為避免公車司機不及反應，僅可預約距離該站5分鐘以上之公車。 \n\n4. 公車即將進站時，請確實站在指定候車區，以利公車司機辨識。 \n\n5. App 會請您確認上車以及下車狀態，以便及時推播公車動態或提供相關協助。"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nowLabel.accessibilityElementsHidden = true
        nextLabel.accessibilityElementsHidden = true
        nowFuncLabel.accessibilityElementsHidden = true
        changeFuncLabel.accessibilityElementsHidden = true
        changeBtn.accessibilityLabel = "現在頁面為。" + funcTitle[0] + "。點擊切換為。" + funcTitle[1]
        
        self.title = "使用說明"
        
        changeBtn.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
        
        nowFuncLabel.text = funcTitle[0]
        changeFuncLabel.text = funcTitle[1]
        contextView.text = content[0]
    }
    

    @objc func clickButton() {
        status = (status + 1 ) % 2
        changeBtn.accessibilityLabel = "現在頁面為。" + funcTitle[status] + "。點擊切換為。" + funcTitle[(status + 1) % 2]
        nowFuncLabel.text = funcTitle[status]
        changeFuncLabel.text = funcTitle[(status + 1) % 2]
        contextView.text = content[status]
        
    }

}
