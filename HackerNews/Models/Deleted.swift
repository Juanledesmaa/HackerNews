//
//  Deleted.swift
//  HackerNews
//
//  Created by juan ledesma on 16/6/18.
//  Copyright © 2018 juanLedesma. All rights reserved.
//

import Foundation

import RealmSwift
import ObjectMapper

class Deleted: Object {
    @objc dynamic var storyId = 0
    @objc dynamic var author = ""
    
    required convenience init?(map: Map) {
        self.init()
    }
}
