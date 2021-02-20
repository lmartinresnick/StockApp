//
//  HomeView.swift
//  YOKExRHCLONE
//
//  Created by Luke Martin-Resnick on 2/18/21.
//

import SwiftUI

struct HomeView: View {
    
    @State var index = 0
    @State var edit: Bool = false
    @StateObject var stockViewModel = StockViewModel()
    @State var startAnimating: Bool = true
    var provider: Provider? = Provider.finnhub
    var stocks: Set<ListStockData>
    @Binding var loadStockArray: Set<LoadStockData>
    @State var didAppear = false
    var coreStocks = ObserverCoreData.shared
    var loadStocks = ["TSLA", "BCRX", "CRSR", "AAPL", "ELY", "GME"]
    
    var color: Color?
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Stocks")
                    .font(Font.custom("CapsuleSansText", size: 35))
                    .padding(.top, 50)
                    .padding(.horizontal)
                ScrollView(.vertical) {
                    VStack(alignment: .leading) {
                        HStack(alignment: .center) {
                            Text("My Stocks🛸")
                                .font(Font.custom("CapsuleSansText", size: 25))
                                .padding(.top)
                                .padding(.horizontal)
                            Spacer()
                            Button(action: {
                                self.edit.toggle()
                            }) {
                                
                                if self.edit {
                                    Image(systemName: "xmark.circle")
                                        .resizable()
                                        .scaleEffect(CGSize(width: 1.5, height: 1.5))
                                        .foregroundColor(.red)
                                        .background(Circle().foregroundColor(.white))
                                        .frame(width: 15, height: 15)
                                } else {
                                    Image(systemName: "pencil.circle.fill")
                                        .resizable()
                                        .scaleEffect(CGSize(width: 1.5, height: 1.5))
                                        .foregroundColor(.blue)
                                        .background(Circle().foregroundColor(.white))
                                        .frame(width: 15, height: 15)
                                }
                                //self.edit ? Image(systemName: "xmark.circle") : Image(systemName: "pencil.circle.fill")
                            }
                            .padding(.top)
                            .padding(.trailing, 22)
                        }
                        
                        ForEach(Array(stocks), id: \.symbol) { stockData in
                            ListView(color: stockData.priceChange!.contains("-") ? Color.red : Color.green, symbol: stockData.symbol, company: stockData.name, chart: stockData.priceChange!.contains("-") ? "redChart" : "greenChart" , price: stockData.price ?? "No data found", edit: edit, id: stockData.id, coreStocks: coreStocks)

                        }.onDelete(perform: swipeDelete)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("List🚀")
                            .font(Font.custom("CapsuleSansText", size: 25))
                            .padding(.top, 50)
                            .padding(.horizontal)
                        if(startAnimating) {
                            ProgressView("Loading...")
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            ForEach(Array(loadStockArray), id: \.symbol) { loadingStock in
                                ListView(color: loadingStock.priceChange!.contains("-") ? Color.red : Color.green, symbol: loadingStock.symbol, company: loadingStock.name ?? "No Data Found", chart: loadingStock.priceChange!.contains("-") ? "redChart" : "greenChart", price: loadingStock.price ?? "No data found", coreStocks: coreStocks)
                            }
                        }
                        
                    }
                }
                
                
            }.navigationBarHidden(true)
        }
        .onAppear(perform: getLoadingStocks)
    }
    func getLoadingStocks() {
        if !didAppear {
            startAnimating = true
            for loadStock in loadStocks {
                provider?.getQuote(loadStock) { (quote) in
                    //startAnimating = false
                    guard let stockQuote = quote else { return }
                    //startAnimating = true
                    Finnhub.getDetail(loadStock) { (profile, news, image) in
                        startAnimating = false
                        guard let stockProfile = profile else { return }
                        let name = stockProfile.name
                        let newLoadStock = LoadStockData(symbol: loadStock, name: name, price: stockQuote.priceAttributedValue.string, priceChange: stockQuote.changeValue.string)
                        loadStockArray.insert(newLoadStock)
                        
                    }
                }
            }
        }
        didAppear = true
        
    }
    func swipeDelete(at offsets: IndexSet) {
        self.coreStocks.delete(id: stocks[stocks.index(stocks.startIndex, offsetBy: offsets.first!)].id)
    }
}

struct MyStocks {

    var symbols: [String] {
        return list.compactMap { $0.symbol }
    }

    fileprivate var dataSource: [Section] {
        var sections: [Section] = []

        let section = Section(items: list)
        sections.append(section)

        return sections
    }

    fileprivate func load() -> [Item] {
        return list
    }

    fileprivate mutating func save(_ items: [Item]) {
        self.list = items
    }

    private var list: [Item] = UserDefaultsConfig.list {
        didSet {
            UserDefaultsConfig.list = list
        }
    }

}

private struct UserDefaultsConfig {

    @UserDefault("list", defaultValue: [])
    fileprivate static var list: [Item]

}

private struct Section {
    
    var header: String?
    var items: [Item]?

}


