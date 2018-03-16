//
//  ViewController.swift
//  TouchStatusBarDemo
//
//  Created by 段奥 on 15/03/2018.
//  Copyright © 2018 DATree. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let cellId = "kCellId"
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(statusBeClick),
                                               name: NSNotification.Name.init(AppDelegate.NotificationKey.kTapStatusNotification),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(statusBeClick),
                                               name: NSNotification.Name.init(AppDelegate.NotificationKey.kDoubleTapStatusNotification),
                                               object: nil)
    }
    
}

extension ViewController {
    
    @objc
    func statusBeClick(_ notification: Notification) {
        print(notification.name.rawValue)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
}


