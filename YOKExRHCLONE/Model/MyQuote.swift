//
//  MyQuote.swift
//  YOKExRHCLONE
//
//  Created by Luke Martin-Resnick on 2/18/21.
//

import Foundation
import SwiftUI

struct MyQuote: Codable, Identifiable, Hashable {
    
    var id = UUID()
    var price: Double
    var change: Double
}

extension MyQuote {
    
    var percent: Double {
        return change / price * 100
    }
    
    var changeValue: NSAttributedString {
        var strings: [String] = []
        
        if let value = change.displaySign {
            strings.append(value)
        }
        
        let str = strings.joined(separator: MyQuote.separator)
        
        let attributes = MyQuote.attributesForChange(change)
        
        return NSAttributedString(string: str, attributes: attributes)
    }
    
    
    var percentValue: NSAttributedString {
        var strings: [String] = []

        if let value = percent.displaySign {
            strings.append( "\(value)%" )
        }

        let attributes = MyQuote.attributesForChange(change)

        let str = strings.joined(separator: MyQuote.separator)

        return NSAttributedString(string: str, attributes: attributes)
    }
    
    var priceAttributedValue: NSAttributedString {
        var strings: [String] = []
        if let display = price.display {
            strings.append(display)
        }
        
        let attributes = MyQuote.attributesForChange(change)
        let str = strings.joined(separator: MyQuote.separator)
        
        return NSAttributedString(string: str, attributes: attributes)
    }
    
}

private extension MyQuote {
    
    static let separator = " · "
    
    static func attributesWithColor(_ color: UIColor) -> [NSAttributedString.Key: Any] {
        let font = UIFont.monospacedSystemFont(ofSize: 15, weight: .regular)
        let attributes: [NSAttributedString.Key: Any] = [.font:font, .foregroundColor: color]
        return attributes
    }
    
    static func attributesForChange(_ change: Double) -> [NSAttributedString.Key: Any] {
        return change > 0 ?
            attributesWithColor(.systemGreen):
            attributesWithColor(.systemRed)
    }
}
