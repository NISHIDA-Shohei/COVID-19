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

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "MainTableViewCell")
    
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadData()
    }
    
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberLabelList.count
     }
    
    // cellの情報を書き込む関数
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}

extension JapanTableViewController {
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
    }
}
