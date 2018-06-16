//
//  Tools.swift
//  HackerNews
//
//  Created by juan ledesma on 16/6/18.
//  Copyright © 2018 juanLedesma. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import RealmSwift
import Realm
import MobileCoreServices

func startLoading(view : UIView) {
    let frame = view.frame
    let centerY = (frame.height / 2)
    let centerX = (frame.width / 2)
    let activity = NVActivityIndicatorView(frame: CGRect(x: centerX - 50, y: centerY - 50, width: 100, height: 100), type: NVActivityIndicatorType(rawValue: NVActivityIndicatorType.ballScaleMultiple.rawValue), color: UIColor.cyan, padding: 0)
    activity.tag = 979
    view.isUserInteractionEnabled = false
    view.addSubview(activity)
    activity.startAnimating()
}


func stopLoading(view : UIView) {
    if let viewWithTag = view.viewWithTag(979) {
        viewWithTag.removeFromSuperview()
        view.isUserInteractionEnabled = true
    } else {
        print("tag not found")
    }
}

func migrateRealm() -> Realm {
    let config = Realm.Configuration(
        schemaVersion: 5,
        migrationBlock: { migration, oldSchemaVersion in
            if (oldSchemaVersion < 5) {}
    })
    
    Realm.Configuration.defaultConfiguration = config
    
    let realm = try! Realm()
    return realm
}

func checkConnection() -> Bool {
    if Reachability.isConnectedToNetwork(){
        return true
    } else {
        return false
    }
}


extension Date {
    func timeAgoDisplay() -> String {
        
        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        if minuteAgo < self {
            let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
            return "\(diff) sec ago"
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
            return "\(diff) min ago"
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
            return "\(diff) hrs ago"
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            return "\(diff) days ago"
        }
        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
        return "\(diff) weeks ago"
    }
}
