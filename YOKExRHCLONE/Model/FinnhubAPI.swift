//
//  FinnhubAPI.swift
//  YOKExRHCLONE
//
//  Created by Luke Martin-Resnick on 2/18/21.
//

import Foundation
import SwiftUI

// API Model

struct Finnhub : Codable {
    
    struct Profile : Codable {
        var country : String
        var currency : String
        var exchange : String
        var ipo : String
        var marketCapitalization : Double
        var name : String
        var phone : String
        var shareOutstanding : Double
        var ticker : String
        var weburl : URL
        var logo : String?
        var finnhubIndustry : String
    }
    
    struct News : Codable {
        var category : String
        var datetime : Int
        var headline : String
        var id : Int
        var image : URL?
        var related : String
        var source : String
        var summary : String
        var url : URL
    }
    
    struct Quote : Codable {
        var c : Double
        var h : Double
        var l : Double
        var o : Double
        var pc : Double
        var t : Int
    }
    
    struct Symbol : Codable {
        var id: String?
        var description : String
        var displaySymbol : String
        var symbol : String
        var type : String
        var currency : String
    }
    
//    struct Metric : Codable {
//        var tenDayAverageTradingVolume: Double
//        var fiveHigh: Double
//        var fiveLow: Double
//
//    }
}

extension Finnhub {
    static var dateFormatter : DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter
    }
    
    static func getDetail(_ symbol: String?, completion: @escaping (Profile?, [News]?, UIImage?) -> Void) {
        guard let symbol = symbol else { return }
        
        let group = DispatchGroup()
        
        var p : Profile?
        var n : [News]?
        var i : UIImage?
        
        if let url = profile2Url(symbol) {
            group.enter()
            url.get(completion: { (profile: Finnhub.Profile?) in
                p = profile
                group.leave()
                
                if
                    let urlString = profile?.logo,
                    let url = URL(string: urlString) {
                    group.enter()
                    DispatchQueue.global().async {
                        if let data = try? Data(contentsOf: url),
                           let image = UIImage(data: data) {
                            i = image
                            group.leave()
                        }
                        else {
                            group.leave()
                        }
                    }
                }
            })
        }
        
        if let url = newsUrl(symbol) {
            group.enter()
            url.get { (news: [Finnhub.News]?) in
                
                n = news
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(p,n,i)
        }
    }
    
    static func getQuote(_ symbol: String, completion: @escaping (MyQuote?) -> Void) {
        let url = quoteUrl(symbol)
        url?.get { (quote: Finnhub.Quote?) in
            guard let finnQuote = quote else {
                completion(nil)
                return
            }
            
            completion(finnQuote.quote)
        }
    }
    
    static func getSearchResults(_ query: String, completion: @escaping ([Finnhub.Symbol]?) -> Void) {
        let url = symbolUrl()
        url?.get { (results: [Finnhub.Symbol]?) in
            let lower = query.lowercased()
            let filtered = results?.compactMap { $0 }.filter {
                ($0.description).lowercased().contains(lower) || ($0.symbol).lowercased().contains(lower) }
            completion(filtered)
        }
    }
 
 
}

private extension Finnhub.Quote {
    
    var quote: MyQuote {
        return MyQuote(price: c, change: c - pc)
    }
}

    
    
private extension Finnhub {
    
    static let apiKey = "bu4tt0f48v6sjdfq45gg"
    
    static let host = "finnhub.io"
    static let baseUrl = "/api/v1"
    
    enum Endpoint: String {
        case companyNews, profile2, quote, symbol
        
        var path: String {
            switch self {
            case .companyNews:
                return "\(baseUrl)/company-news"
            case .quote:
                return "\(baseUrl)/\(self.rawValue)"
            case .profile2, .symbol:
                return "\(baseUrl)/stock/\(self.rawValue)"
            }
        }
    }
    
    static var baseUrlComponents: URLComponents {
        var c = URLComponents()
        c.scheme = "https"
        c.host = host
        
        return c
    }
    
    static var tokenQueryItem: URLQueryItem {
        let queryItem = URLQueryItem(name: "token", value: apiKey)
        return queryItem
    }
    
    static func url(path: String, queryItems: [URLQueryItem]) -> URL? {
        var c = baseUrlComponents
        c.path = path
        c.queryItems = queryItems
        
        let u = c.url
        
        return u
    }
    
    static func url(path: String, symbol: String?, numberOfDays: TimeInterval? = nil) -> URL? {
        guard let symbol = symbol else { return nil }
        
        let s = URLQueryItem(name: "symbol", value: symbol)
        
        guard let numberOfDays = numberOfDays else {
            let queryItems = [ tokenQueryItem, s]
            
            return url(path: path, queryItems: queryItems)
        }
        
        let fromDate = Date().addingTimeInterval(-numberOfDays * 24 * 60 * 60)
        let from = dateFormatter.string(from: fromDate)
        let fromQi = URLQueryItem(name: "from", value: from)
        
        let to = dateFormatter.string(from: Date())
        let toQi = URLQueryItem(name: "name", value: to)
        
        let queryItems = [tokenQueryItem, s, fromQi, toQi]
        
        return url(path: path, queryItems: queryItems)
    }
    
}

private extension Finnhub {
    static func newsUrl(_ symbol: String?) -> URL? {
        return url(path: Endpoint.companyNews.path, symbol: symbol, numberOfDays: 14)
    }
    static func profile2Url(_ symbol: String) -> URL? {
        return url(path: Endpoint.profile2.path, symbol: symbol)
    }
    static func quoteUrl(_ symbol: String) -> URL? {
        return url(path: Endpoint.quote.path, symbol: symbol)
    }
    static func symbolUrl(_ exchange: String = "US") -> URL? {
        var c = baseUrlComponents
        c.path = Endpoint.symbol.path
        
        let exchangeQi = URLQueryItem(name: "exchange", value: exchange)
        c.queryItems = [exchangeQi,tokenQueryItem]
        
        let u = c.url
        return u
    }
}
