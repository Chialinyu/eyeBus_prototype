//
//  SearchBusResultTableViewController.swift
//  BusPlusA
//
//  Created by iui on 2019/12/8.
//  Copyright © 2019 Carolyn Yu. All rights reserved.
//

import UIKit

class SearchBusResultCell:UITableViewCell {
    @IBOutlet weak var busNameLabel: UILabel!
}

class SearchBusResultTableViewController: UITableViewController {

    var keyWord = "幹線"
    
    let resultBusList = ["1 5 和平幹線", "7 4 復興幹線", "2 2 0 中山幹線", "2 3 2 副 忠孝幹線", "2 3 6 羅斯福路幹線", "2 6 3 仁愛幹線", "2 6 6 承德幹線", "2 8 5 敦化幹線", "棕 9 南京幹線", "紅 3 2 民權幹線"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "\"" + keyWord + "\" 搜尋結果"
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return resultBusList.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchBusResultCell", for: indexPath) as! SearchBusResultCell

        cell.busNameLabel.text = resultBusList[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let searchBusStopView = storyboard?.instantiateViewController(withIdentifier: "searchBusStopViewID") as! SearchBusStopListViewController

        searchBusStopView.isFromFav = 0
        searchBusStopView.busName = self.resultBusList[indexPath.row]

        navigationController?.pushViewController(searchBusStopView, animated: true)
    }
    

}
