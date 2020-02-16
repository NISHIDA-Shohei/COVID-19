//
//  WorldWideTableViewController.swift
//  COVID-19
//
//  Created by 西田翔平 on 2020/02/15.
//  Copyright © 2020 西田翔平. All rights reserved.
//

import UIKit
import Firebase

class WorldWideTableViewController: UITableViewController {
    
    var db: Firestore!
    var countryNameList:[String] = []
    var countryNumberList:[String] = []
    
    let dataTypeLabelList = ["感染者数", "死亡者数", "回復者数"]
    var overAllNumberList:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "WorldWideTableViewCell", bundle: nil), forCellReuseIdentifier: "WorldWideTableViewCell")
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "MainTableViewCell")
    
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        loadData()
        loadTitle()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        } else {
            return "国別感染者数"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 40
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        //labelの色
        view.tintColor = UIColor(named: "SystemDarkBackground")
        view.alpha = 0.95
        let header = view as! UITableViewHeaderFooterView
        //labelの文字の色
        header.textLabel?.textColor = UIColor(named: "SystemReverseBackground")
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
    }
    
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return overAllNumberList.count
        } else {
            return countryNumberList.count
        }
     }
    
    // cellの情報を書き込む関数
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
            cell.tag = indexPath.row
            if cell.tag == 0 {
                cell.numberLabel.textColor = UIColor.white
            } else if cell.tag == 1 {
                cell.numberLabel.textColor = UIColor(named: "SystemRed")
            } else if cell.tag == 2 {
                cell.numberLabel.textColor = UIColor(named: "SystemGreen")
            }
            cell.dataTypeLabel.text = dataTypeLabelList[indexPath.row]
            cell.numberLabel.text = overAllNumberList[indexPath.row]
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WorldWideTableViewCell", for: indexPath) as! WorldWideTableViewCell
            cell.numberLabel.textColor = UIColor.white
            cell.placeNameLabel.text = countryNameList[indexPath.row]
            cell.numberLabel.text = countryNumberList[indexPath.row]
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 140
        } else {
            return 120
        }
    }
}

extension WorldWideTableViewController {
    
    func loadTitle() {
        db.collection("lastUpdated").getDocuments() {(snapshot, error) in
            if error != nil {
                print("error")
            } else {
                for document in (snapshot?.documents)! {
                    if let lastUpdated = document.data()["lastUpdated"] as? String {
                        self.navigationItem.title = "全世界 \(lastUpdated)"
                    }
                }
            }
        }
    }
    func loadData() {
        db.collection("worldWide").order(by: "infected", descending: true).getDocuments() {(snapshot, error) in
            self.countryNameList = []
            self.countryNumberList = []
            if error != nil {
                print("error")
            } else {
                for document in (snapshot?.documents)! {
                    if let name = document.data()["countryName"] as? String {
                        if let infected = document.data()["infected"] as? Int {
                            self.countryNameList.append(name)
                            let infectedString = String(infected.withComma)
                            self.countryNumberList.append(infectedString)
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
        
        db.collection("overAll").getDocuments() {(snapshot, error) in
            if error != nil {
                print("error")
            } else {
                for document in (snapshot?.documents)! {
                    if let dead = document.data()["dead"] as? Int {
                        if let infected = document.data()["infected"] as? Int {
                            if let recovered = document.data()["recovered"] as? Int {
                                let deadString = String(dead.withComma)
                                let infectedString = String(infected.withComma)
                                let recoveredString = String(recovered.withComma)
                                self.overAllNumberList = []
                                self.overAllNumberList.append(infectedString)
                                self.overAllNumberList.append(deadString)
                                self.overAllNumberList.append(recoveredString)
                                self.tableView.reloadData()
                                
                            }
                        }
                    }
                }
            }
        }
    }
}
