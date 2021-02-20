//
//  Provider.swift
//  YOKExRHCLONE
//
//  Created by Luke Martin-Resnick on 2/18/21.
//

import Foundation
import SwiftUI


enum Provider: String {
    
    case finnhub
    
    func getDetail(_ symbol: String?, completion: @escaping ([DetailSection], UIImage?) -> Void) {
        switch self {
        case .finnhub:
            Finnhub.getDetail(symbol) { (profile, news, image) in
                var sections: [DetailSection] = []
                
                if let s = profile?.sections {
                    sections.append(contentsOf: s)
                }
                
                if let s = DetailSection.section(news) {
                    sections.append(s)
                }
                completion(sections,image)
            }
        }
    }
    
    
    
    func getQuote(_ symbol: String?, completion: @escaping (MyQuote?) -> Void) {
        guard let symbol = symbol else {
            completion(nil)
            return
        }
        
        switch self {
        case .finnhub:
            let validSymbol = symbol.replacingOccurrences(of: "-", with: ".")
            Finnhub.getQuote(validSymbol) { (m) in
                completion(m)
            }
        }
    }
    
    func search(_ query: String, completion: @escaping ([AddItem]?) -> Void) {
        switch self {
        case .finnhub:
            Finnhub.getSearchResults(query) { (results) in
                let items = results?.compactMap { $0.item }
                completion(items)
            }
        }
    }
}

private extension Finnhub.Symbol {
    
    var item: AddItem {
        
        let inList = MyStocks().symbols.contains(symbol)
        
        return AddItem(title: symbol, subtitle: description, alreadyInList: inList)
    }
}

private extension String {
    var wikipediaUrl: URL? {
        let baseUrl = "https://en.wikipedia.org/wiki"
        let item = self.replacingOccurrences(of: " ", with: "_")
        return URL(string: "\(baseUrl)/\(item)")
    }
}

private extension Int {
    
    var largeNumberDisplay: String? {
        if self < 1_000_000 {
            return self.display
        }
        
        let m: Double = Double(self) / 1_000_000
        
        return String(format: "%.2fM", m)
    }
}

extension Double {
    
    var fh_largeNumberDisplay: String? {
        if self < 1000 {
            return "\(self.display ?? "")M"
        }
        
        let b = self / 1000
        return "\(b.display ?? "")B"
    }
}

extension Finnhub.Profile {
    
    var sections: [DetailSection]? {
        var sections: [DetailSection] = []
        
        if let section = mainSection {
            sections.append(section)
        }
        
        if let section = exchangeSection {
            sections.append(section)
        }
        
        return sections
    }
    
    var marketCapDisplay: String? {
        if marketCapitalization < 1000 {
            return "\(marketCapitalization.currency ?? "")M"
        }
        
        let b = marketCapitalization / 1000
        if b < 1000 {
            return "\(b.currency ?? "")B"
        }
        
        let t = b / 1000
        return "\(t.currency ?? "")T"
    }
    
    var mainSection: DetailSection? {
        var items: [DetailItem] = []
        
        let nameItem = DetailItem(subtitle: weburl.absoluteString, title: name, url: weburl)
        items.append(nameItem)
        
        if let value = marketCapDisplay {
            let marketCapItem = DetailItem(subtitle: "Market Capitalization", title: value)
            items.append(marketCapItem)
        }
        
        let section = DetailSection(header: finnhubIndustry, items: items)
        
        return section
    }
    
    var exchangeSection: DetailSection? {
        var items: [DetailItem] = []
        
        if let value = ipoTimeAgo {
            let ipoItem = DetailItem(subtitle: "\(ipoDisplay ?? "") IPO", title: value)
            items.append(ipoItem)
        }
        
        var string: [String] = ["Shares Outstanding"]
        string.append(country)
        string.append(currency)
        let sharesItem = DetailItem(subtitle: string.joined(separator: " · "), title: "\(shareOutstanding.fh_largeNumberDisplay ?? "")")
        items.append(sharesItem)
        
        let section = DetailSection(header: exchange, items: items)
        
        return section
    }
    
    var ipoDate: Date? {
        return Finnhub.dateFormatter.date(from: ipo)
    }
    
    var ipoDisplay: String? {
        guard let ipoDate = ipoDate else { return nil }
        let df = DetailView.displayDateFormatter
        
        return df.string(from: ipoDate)
    }
    
    var ipoTimeAgo: String? {
        guard let ipoDate = ipoDate else { return nil }
        
        let rdf = RelativeDateTimeFormatter()
        
        return rdf.localizedString(for: ipoDate, relativeTo: Date())
    }
}

private extension DetailItem {
    
    var isUrl: Bool? {
        guard
            let value = subtitle,
            value.contains("https") else { return nil }
        
        return true
    }
}

private extension DetailSection {
    
    static func section(_ news: [Finnhub.News]?) -> DetailSection? {
        let items = news?.compactMap { $0.item }
        guard items?.count ?? 0 > 0 else { return nil }
        
        let section = DetailSection(header: "news", items: items)
        
        return section
    }
}

private extension DetailView {
    
    static var displayDateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        
        return df
    }
}

private extension Finnhub.News {
    
    var item: DetailItem? {
        var sub: [String] = []
        
        let date = Date(timeIntervalSince1970: TimeInterval(datetime))
        let rdf = RelativeDateTimeFormatter()
        let ago = rdf.localizedString(for: date, relativeTo: Date())
        sub.append(ago)
        
        if let value = sourceDisplay {
            sub.append(value)
        }
        sub.append(summary)
        let detailItem = DetailItem(subtitle: nil, title: nil, url: url, headline: headline, timeAgo: ago, source: sourceDisplay, image: image)
        return detailItem
    }
    
    var sourceDisplay: String? {
        return source
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "www.", with: "")
    }
}



private extension Int {
    
    var display: String? {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 0
        f.locale = Locale(identifier: "en_US")
        
        let number = NSNumber(value: self)
        return f.string(from: number)
    }
}
