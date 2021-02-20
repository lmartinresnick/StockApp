//
//  TimeDisplayMode.swift
//  YOKExRHCLONE
//
//  Created by Luke Martin-Resnick on 2/18/21.
//

import Foundation


enum TimeDisplayOption: String, CaseIterable {
    case hourly           = "1D"
    case daily            = "W"
    case weekly           = "M"
    case monthly          = "Y"
    
    var buttonTitle: String {
        rawValue
    }
    
    func dateFormatter() -> DateFormatter {
        switch self {
        case .hourly: return SharedDateFormatter.timeAndDay
        default: return SharedDateFormatter.dayAndYear
        }
    }
}

struct SharedDateFormatter {
    static let dayAndYear: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter
    }()
    
    static let timeAndDay: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a zzz, MMM d"
        return dateFormatter
    }()
    
    static let onlyTime: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a zzz"
        return dateFormatter
    }()
}

