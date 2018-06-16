//
//  News.swift
//  HackerNews
//
//  Created by juan ledesma on 16/6/18.
//  Copyright © 2018 juanLedesma. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class News: Object, Mappable {
    @objc dynamic var storyId = 0
    @objc dynamic var createdAt = ""
    @objc dynamic var storyTitle = ""
    @objc dynamic var author = ""
    @objc dynamic var storyUrl = ""
    
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        storyId <- map["story_id"]
        createdAt <- map["created_at"]
        storyTitle <- map["story_title"]
        author <- map["author"]
        storyUrl <- map["story_url"]
        
    }
}
