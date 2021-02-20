//
//  StockViewModel.swift
//  YOKExRHCLONE
//
//  Created by Luke Martin-Resnick on 2/18/21.
//

import Foundation
import SwiftUI

final class StockViewModel: ObservableObject {
    // Input
    // Output
    let provider: Provider = Provider.finnhub
    
    @Published var dataSource: [AddSection] = []
    @Published var query: String = ""

    
    
    
    func fetchStock() {
        provider.search(query, completion: { (returnedStocks) in
            let section = AddSection(header: "Search", items: returnedStocks)
            self.dataSource = [section]
        })
            
    }
    
}
