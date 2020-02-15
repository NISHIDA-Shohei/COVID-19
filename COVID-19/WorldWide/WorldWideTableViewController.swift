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
    var numberLabelList:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "WorldWideTableViewCell", bundle: nil), forCellReuseIdentifier: "WorldWideTableViewCell")
    
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadData()
    }
    
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberLabelList.count
     }
    
    // cellの情報を書き込む関数
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorldWideTableViewCell", for: indexPath) as! WorldWideTableViewCell
        
        cell.countryNameLabel.text = countryNameList[indexPath.row]
        cell.numberLabel.text = numberLabelList[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

extension WorldWideTableViewController {
    func loadData() {
        countryNameList = []
        numberLabelList = []
        db.collection("worldWide").order(by: "infected", descending: true).getDocuments() {(snapshot, error) in
            if error != nil {
                print("error")
            } else {
                for document in (snapshot?.documents)! {
                    if let name = document.data()["countryName"] as? String {
                        if let infected = document.data()["infected"] as? Int {
                            self.countryNameList.append(name)
                            let infectedString = String(infected.withComma)
                            self.numberLabelList.append(infectedString)
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
}
