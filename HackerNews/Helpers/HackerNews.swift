//
//  HackerNews.swift
//  HackerNews
//
//  Created by juan ledesma on 16/6/18.
//  Copyright © 2018 juanLedesma. All rights reserved.
//

import Foundation

struct HackerNews {
    struct Api {
        static let server = "https://hn.algolia.com/"
        static let url = server+"api/v1"
        static let search = url+"/search_by_date?query=ios"
    }
}
