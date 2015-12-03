//
//  SearchResult.swift
//  StoreSearch
//
//  Created by huxianming on 15/11/29.
//  Copyright © 2015年 chuanyue. All rights reserved.
//

import Foundation

class SearchResult{
    var name = ""
    var artistName = ""
    var artworkURL60 = ""
    var artworkURL100 = ""
    var storeURL = ""
    var kind = ""
    var currency = ""
    var price = 0.0
    var genre = ""
}

func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .OrderedAscending
}