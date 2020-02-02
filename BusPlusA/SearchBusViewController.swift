//
//  SearchBusViewController.swift
//  BusPlusA
//
//  Created by iui on 2019/12/8.
//  Copyright © 2019 Carolyn Yu. All rights reserved.
//

import UIKit

class SearchBusViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var searchBusTextField: UITextField!
    @IBOutlet weak var searchBusBtn: UIButton!
    @IBOutlet weak var btnText1: UIButton!
    @IBOutlet weak var btnText2: UIButton!
    @IBOutlet weak var btnText3: UIButton!
    @IBOutlet weak var btnText4: UIButton!
    @IBOutlet weak var btnText5: UIButton!
    @IBOutlet weak var btnText6: UIButton!
    @IBOutlet weak var btnText7: UIButton!
    @IBOutlet weak var btnText8: UIButton!
    @IBOutlet weak var btnText9: UIButton!
    @IBOutlet weak var btnTextVoice: UIButton!
    @IBOutlet weak var btnRed: UIButton!
    @IBOutlet weak var btnOrange: UIButton!
    @IBOutlet weak var btnBrown: UIButton!
    @IBOutlet weak var btnGreen: UIButton!
    @IBOutlet weak var btnBlue: UIButton!
    @IBOutlet weak var btnF: UIButton!
    @IBOutlet weak var btnR: UIButton!
    @IBOutlet weak var btnT: UIButton!
    @IBOutlet weak var btnSmall: UIButton!
    @IBOutlet weak var btnNight: UIButton!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var btn5: UIButton!
    @IBOutlet weak var btn6: UIButton!
    @IBOutlet weak var btn7: UIButton!
    @IBOutlet weak var btn8: UIButton!
    @IBOutlet weak var btn9: UIButton!
    @IBOutlet weak var btn0: UIButton!
    @IBOutlet weak var btnDel: UIButton!
    @IBOutlet weak var btnReset: UIButton!
    
    var searchBusText = ""
//    var btnList = ["市民", "幹線", "內科", "先導", "貓空", "跳蛙", "南軟", "懷恩", "其他", "語音"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "搜尋公車"
        // Do any additional setup after loading the view.
        searchBusTextField.delegate = self
        
        searchBusTextField.isUserInteractionEnabled = false
        searchBusTextField.attributedPlaceholder = NSAttributedString(string: "輸入公車號碼",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        searchBusBtn.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
        
        btnTextVoice.accessibilityLabel = "語音輸入"
        
        btnText1.addTarget(self, action: #selector(clickTextBtn), for: .touchUpInside)
        btnText2.addTarget(self, action: #selector(clickTextBtn), for: .touchUpInside)
        btnText3.addTarget(self, action: #selector(clickTextBtn), for: .touchUpInside)
        btnText4.addTarget(self, action: #selector(clickTextBtn), for: .touchUpInside)
        btnText5.addTarget(self, action: #selector(clickTextBtn), for: .touchUpInside)
        btnText6.addTarget(self, action: #selector(clickTextBtn), for: .touchUpInside)
        btnText7.addTarget(self, action: #selector(clickTextBtn), for: .touchUpInside)
        btnText8.addTarget(self, action: #selector(clickTextBtn), for: .touchUpInside)
        btnText9.addTarget(self, action: #selector(clickTextBtn), for: .touchUpInside)
        
        btnRed.addTarget(self, action: #selector(addTextBtn), for: .touchUpInside)
        btnOrange.addTarget(self, action: #selector(addTextBtn), for: .touchUpInside)
        btnBrown.addTarget(self, action: #selector(addTextBtn), for: .touchUpInside)
        btnGreen.addTarget(self, action: #selector(addTextBtn), for: .touchUpInside)
        btnBlue.addTarget(self, action: #selector(addTextBtn), for: .touchUpInside)
        btnF.addTarget(self, action: #selector(addTextBtn), for: .touchUpInside)
        btnR.addTarget(self, action: #selector(addTextBtn), for: .touchUpInside)
        btnT.addTarget(self, action: #selector(addTextBtn), for: .touchUpInside)
        btnSmall.addTarget(self, action: #selector(addTextBtn), for: .touchUpInside)
        btnNight.addTarget(self, action: #selector(addTextBtn), for: .touchUpInside)
        
        btn1.addTarget(self, action: #selector(addNumBtn), for: .touchUpInside)
        btn2.addTarget(self, action: #selector(addNumBtn), for: .touchUpInside)
        btn3.addTarget(self, action: #selector(addNumBtn), for: .touchUpInside)
        btn4.addTarget(self, action: #selector(addNumBtn), for: .touchUpInside)
        btn5.addTarget(self, action: #selector(addNumBtn), for: .touchUpInside)
        btn6.addTarget(self, action: #selector(addNumBtn), for: .touchUpInside)
        btn7.addTarget(self, action: #selector(addNumBtn), for: .touchUpInside)
        btn8.addTarget(self, action: #selector(addNumBtn), for: .touchUpInside)
        btn9.addTarget(self, action: #selector(addNumBtn), for: .touchUpInside)
        btn0.addTarget(self, action: #selector(addNumBtn), for: .touchUpInside)
        
        btnReset.addTarget(self, action: #selector(resetBtn), for: .touchUpInside)
        
//        let busListBtn = UIBarButtonItem(image: UIImage(named: "searchBus_icon_list"), style: .done, target: self, action:#selector(clickListButton) )
//        navigationItem.rightBarButtonItem = busListBtn
//        navigationItem.rightBarButtonItem?.accessibilityLabel = "常用公車列表"
//        navigationItem.rightBarButtonItem?.accessibilityTraits = UIAccessibilityTraits.none

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBusText = searchBusTextField.text ?? ""
        searchBusTextField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    @objc func clickButton() {

        searchBusText = searchBusTextField.text ?? ""
        if searchBusText == "" {
            searchBusText = "幹線"
        }

//        self.view.endEditing(true)
//        searchBusTextField.resignFirstResponder()
//
//        if CFStringHasPrefix(searchBusText as CFString, "棕" as CFString) {
//
//        }
        
        let resultView = storyboard?.instantiateViewController(withIdentifier: "searchBusResultViewID") as! SearchBusResultTableViewController
        
        resultView.keyWord = searchBusText
        
        navigationController?.pushViewController(resultView, animated: true)

    }
    
    @objc func clickTextBtn(sender:UIButton) {
        let resultView = storyboard?.instantiateViewController(withIdentifier: "searchBusResultViewID") as! SearchBusResultTableViewController
        
        resultView.keyWord = sender.titleLabel?.text ?? "其他"
        
        navigationController?.pushViewController(resultView, animated: true)
    }
    
    @objc func addTextBtn(sender:UIButton) {
        searchBusTextField.text = sender.titleLabel!.text ?? ""
        searchBusText = sender.titleLabel!.text ?? ""
    }
    
    @objc func addNumBtn(sender:UIButton) {
        searchBusTextField.text = searchBusText + (sender.titleLabel!.text ?? "")
        searchBusText = searchBusText + (sender.titleLabel!.text ?? "")
    }
    
    @objc func resetBtn(sender:UIButton) {
        searchBusTextField.text = ""
        searchBusText = ""
    }
    
    
    @objc func clickListButton() {
        let resultView = storyboard?.instantiateViewController(withIdentifier: "favBusViewID") as! FavBusTableViewController
                
        navigationController?.pushViewController(resultView, animated: true)
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
