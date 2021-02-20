//
//  RHChartAPIResponse.swift
//  YOKExRHCLONE
//
//  Created by Luke Martin-Resnick on 2/18/21.
//

import Foundation

struct StockStatsInfo: Decodable {
    enum CodingKeys: String, CodingKey {
        case closePrice = "4. close"
    }
    
    let closePrice: Float
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let close = Float(try container.decode(String.self, forKey: .closePrice)) else {
            throw DecodingError.dataCorruptedError(forKey: CodingKeys.closePrice, in: container, debugDescription: "`close` should be convertible to float.")
        }
        self.closePrice = close
    }
}

struct RHChartAPIResponse: Decodable {
    
    let symbol: String
    let timeSeries: [(time: Date, info: StockStatsInfo)]
    
    private struct PhantomKey: CodingKey {
        var intValue: Int?
        var stringValue: String
        init?(intValue: Int) { self.intValue = intValue; self.stringValue = "\(intValue)" }
        init?(stringValue: String) { self.stringValue = stringValue }
    }
    
    private enum MetaDataKeys: String, CodingKey {
        case symbol = "2. Symbol"
    }

    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: PhantomKey.self)
        let timeSeriesKey = root.allKeys
            .first(where: { (k: PhantomKey) -> Bool in
                k.stringValue.contains("Time Series")
            })
        
        
        guard let key = timeSeriesKey else {
            
            // ONLY CAN MAKE 5 API CALLS A MINUTE SO TIMESERIESKEY = NIL
            // APP WILL NOT CRASH BUT CONTINUING IN LOADING PHASE
            
            
            //let container = try root.nestedContainer(keyedBy: PhantomKey.self, forKey: key)
            var entities: [(time: Date, info: StockStatsInfo)] = []

            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "EST")
            
            let dateFormat = decoder.userInfo[CodingUserInfoKey(rawValue: "dateFormat")!] as! String
            dateFormatter.dateFormat = dateFormat
            for key in root.allKeys {
                let entity = try root.decode(StockStatsInfo.self, forKey: key)
                let keyString = key.stringValue
                entities.append((dateFormatter.date(from: keyString)!, entity))
            }
            self.timeSeries = entities.sorted(by: { (v1, v2) -> Bool in
                v1.time < v2.time
            })
            
            
            
            self.symbol = ""
            
            return
            //fatalError("Expect time series key in Alphavantage API. All keys = \(root.allKeys)")
        }

        let container = try root.nestedContainer(keyedBy: PhantomKey.self, forKey: key)
        var entities: [(time: Date, info: StockStatsInfo)] = []

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        
        let dateFormat = decoder.userInfo[CodingUserInfoKey(rawValue: "dateFormat")!] as! String
        dateFormatter.dateFormat = dateFormat
        for key in container.allKeys {
            let entity = try container.decode(StockStatsInfo.self, forKey: key)
            let keyString = key.stringValue
            entities.append((dateFormatter.date(from: keyString)!, entity))
        }
        self.timeSeries = entities.sorted(by: { (v1, v2) -> Bool in
            v1.time < v2.time
        })
        
        // Symbol
        let symbolKey = PhantomKey(stringValue: "Meta Data")!
        let metaDataContainer = try root.nestedContainer(keyedBy: MetaDataKeys.self, forKey: symbolKey)
        self.symbol = try metaDataContainer.decode(String.self, forKey: .symbol)
    }
}

