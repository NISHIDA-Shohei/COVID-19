//
//  InformationTableViewController.swift
//  COVID-19
//
//  Created by 西田翔平 on 2020/02/18.
//  Copyright © 2020 西田翔平. All rights reserved.
//

import UIKit
import Firebase

class InformationTableViewController: UITableViewController {

    @IBOutlet weak var lastUpdatedLabel: UILabel!
    
    var db: Firestore!
    var titleLabelList:[String] = []
    var contentLabelList:[String] = []
    
    let refreshCtl = UIRefreshControl()
    var observer: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "Pixel30TableViewCell", bundle: nil), forCellReuseIdentifier: "Pixel30TableViewCell")
    
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        navigationController?.navigationBar.largeTitleTextAttributes = [.font : UIFont.boldSystemFont(ofSize: 27.0)]
        
        loadData()
        loadTitle()
        
        tableView.refreshControl = refreshCtl
        refreshCtl.addTarget(self, action: #selector(WorldWideTableViewController.refresh(sender:)), for: .valueChanged)
        
        
    }
    
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleLabelList.count
     }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 120 //セルの高さ
        return UITableView.automaticDimension //自動設定
    }
    
    // cellの情報を書き込む関数
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Pixel30TableViewCell", for: indexPath) as! Pixel30TableViewCell
        cell.titleLabel.text = titleLabelList[indexPath.row]
        cell.contentLabel.text = contentLabelList[indexPath.row]
        
        return cell
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        loadData()
        loadTitle()
        refreshCtl.endRefreshing()
    }
}

extension InformationTableViewController {
    
    func loadTitle() {
        db.collection("lastUpdated").getDocuments() {(snapshot, error) in
            if error != nil {
                print("error")
            } else {
                for document in (snapshot?.documents)! {
                    if let lastUpdated = document.data()["lastUpdated"] as? String {
                        self.lastUpdatedLabel.text = lastUpdated
                    }
                }
            }
        }
    }
    func loadData() {
        db.collection("information").whereField("type", isEqualTo: "info1").getDocuments{(snapshot, error) in
            self.titleLabelList = []
            self.contentLabelList = []
            if error != nil {
                print("error")
            } else {
                for document in (snapshot?.documents)! {
                    if let title = document.data()["title"] as? String {
                        if let content = document.data()["content"] as? String {
                            self.titleLabelList.append(title)
                            self.contentLabelList.append(content)
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
}
