//
//  SearchResults.swift
//  YOKExRHCLONE
//
//  Created by Luke Martin-Resnick on 2/18/21.
//

import SwiftUI

struct SearchResults: View {
    var searchResult: AddItem
    @Binding var selectedItem: AddItem?
    @Binding var stocks: Set<ListStockData>
    let provider: Provider = Provider.finnhub
    @State private var showingAlert = false
    @State var coreStocks = ObserverCoreData.shared
    //@EnvironmentObject var coreStocks = ObserverCoreData()
    
    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(searchResult.title ?? "No data found")
                        .font(Font.custom("CapsuleSansText", size: 15))
                    Text(searchResult.subtitle ?? "")
                        .font(Font.custom("CapsuleSansText", size: 13))
                        .foregroundColor(Color.gray)
                }
                Spacer()
                
                NavigationLink(destination: RHChartView(symbol: selectedItem?.title ?? "No data")) {
                }
                searchResult == selectedItem ? Image(systemName: "checkmark.circle.fill").foregroundColor(Color.blue) : Image(systemName: "plus.circle").foregroundColor(Color.blue)
            }
        }.onTapGesture {
            self.selectedItem = self.searchResult
            print("Selected... ", self.searchResult)
            guard let symbol = searchResult.title, let description = searchResult.subtitle else { return }
            provider.getQuote(symbol) { (quote) in
                guard let stockQuote = quote else { return }
                let newStock = ListStockData(symbol: symbol, name: description, price: stockQuote.priceAttributedValue.string, priceChange: stockQuote.changeValue.string, percentChange: stockQuote.percentValue.string)

                if stocks.contains(newStock) {
                    self.showingAlert = true
                    print("pop up something")

                } else {
                    stocks.insert(newStock)
                    
//                    let coreStocks = ObserverCoreData.shared
                    coreStocks.add(id: newStock.id, name: newStock.name, symbol: newStock.symbol, price: newStock.price ?? "Unknown price", priceChange: newStock.priceChange ?? "Unknown Change")
                }
            }
        }.alert(isPresented: $showingAlert) {
            Alert(title: Text("Uh Oh!"), message: Text("\(searchResult.title ?? "Stock") is already in list"), dismissButton: .default(Text("Got it!")))
        }
    }
    
}
