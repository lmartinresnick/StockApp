//
//  Item.swift
//  YOKExRHCLONE
//
//  Created by Luke Martin-Resnick on 2/18/21.
//

import Foundation


struct Item: Codable {
    
    var symbol: String?
    var quote: MyQuote?
}

extension Item: Equatable {
    
    static func ==(lhs: Item, rhs: Item) -> Bool {
        return lhs.symbol == rhs.symbol
    }
}
