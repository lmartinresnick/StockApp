//
//  StockData.swift
//  YOKExRHCLONE
//
//  Created by Luke Martin-Resnick on 2/18/21.
//

import Foundation
import SwiftUI

struct ListStockData : Identifiable, Hashable {
    // took out Codable protocol for NSAttStrings to conform
    var id = UUID()
    var symbol: String
    var name: String
    var price: String?
    var priceChange: String?
    var percentChange: String?
    var open: String?
    var high: String?
    var close: String?
    var marketCap : String?
    var shares: String?
    var logo: UIImage?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(symbol)
    }
    
    static func == (lhs: ListStockData, rhs: ListStockData) -> Bool {
        return lhs.symbol == rhs.symbol
    }
}

var listStockDataArray : Set<ListStockData> = []
var loadStockArray : Set<LoadStockData> = []

struct LoadStockData : Identifiable, Hashable {
    // took out Codable protocol for NSAttStrings to conform
    var id = UUID()
    var symbol: String
    var name: String?
    var price: String?
    var priceChange: String?
    var percentChange: String?
    var open: String?
    var high: String?
    var close: String?
    var marketCap : String?
    var shares: String?
    var logo: UIImage?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(symbol)
    }
}

