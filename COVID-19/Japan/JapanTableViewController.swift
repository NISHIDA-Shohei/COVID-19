//
//  JapanTableViewController.swift
//  COVID-19
//
//  Created by 西田翔平 on 2020/02/15.
//  Copyright © 2020 西田翔平. All rights reserved.
//

import UIKit
import Firebase

class JapanTableViewController: UITableViewController {
    
    var db: Firestore!
    let dataTypeLabelList = ["感染者数", "死亡者数", "回復者数"]
    var numberLabelList:[String] = []
    
    var placeLabelList:[String] = []
    var detailNumberLabelList:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "MainTableViewCell")
        tableView.register(UINib(nibName: "WorldWideTableViewCell", bundle: nil), forCellReuseIdentifier: "WorldWideTableViewCell")
    
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        loadData()
        loadTitle()
        
        navigationItem.title = "aaa"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        } else {
            return "詳細情報"
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
            return numberLabelList.count
        } else {
            return placeLabelList.count
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
                cell.numberLabel.textColor = UIColor.red
            } else if cell.tag == 2 {
                cell.numberLabel.textColor = UIColor.green
            }
            cell.dataTypeLabel.text = dataTypeLabelList[indexPath.row]
            cell.numberLabel.text = numberLabelList[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WorldWideTableViewCell", for: indexPath) as! WorldWideTableViewCell
            cell.placeNameLabel.text = placeLabelList[indexPath.row]
            cell.numberLabel.text = detailNumberLabelList[indexPath.row]
            cell.numberLabel.textColor = UIColor.white
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

extension JapanTableViewController {
    
    func loadTitle() {
        db.collection("lastUpdated").getDocuments() {(snapshot, error) in
            if error != nil {
                print("error")
            } else {
                for document in (snapshot?.documents)! {
                    if let lastUpdated = document.data()["lastUpdated"] as? String {
                        self.navigationItem.title = "日本国内 \(lastUpdated)"
                    }
                }
            }
        }
    }
    func loadData() {
        db.collection("Japan").getDocuments() {(snapshot, error) in
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
                                self.numberLabelList = []
                                self.numberLabelList.append(infectedString)
                                self.numberLabelList.append(deadString)
                                self.numberLabelList.append(recoveredString)
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
        
        
        db.collection("JapanDetail").order(by: "cases", descending: true).getDocuments() {(snapshot, error) in
            if error != nil {
                print("error")
            } else {
                self.placeLabelList = []
                self.detailNumberLabelList = []
                for document in (snapshot?.documents)! {
                    if let place = document.data()["place"] as? String {
                        if let cases = document.data()["cases"] as? Int {
                            let casesString = String(cases.withComma)
                            self.placeLabelList.append(place)
                            self.detailNumberLabelList.append(casesString)
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
}
