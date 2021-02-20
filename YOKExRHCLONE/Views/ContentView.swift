//
//  ContentView.swift
//  YOKExRHCLONE
//
//  Created by Luke Martin-Resnick on 2/18/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State var selection = 0
    @StateObject var stockViewModel = StockViewModel()
    @State var stocks: Set<ListStockData> = listStockDataArray
    @State var loadingStocks : Set<LoadStockData> = loadStockArray
    @State var startAnimating: Bool = true
    
    @StateObject var coreData = ObserverCoreData.shared
    @State var showLaunch = true
    
    var body: some View {
        ZStack {
            TabView(selection: self.$selection) {
                HomeView(stocks: coreData.coreStocks, loadStockArray: $loadingStocks).tag(0)
                    .tabItem {
                        Image(systemName: "crown.fill")
                        Text("💸💸")
                    }
                SearchView(stocks: $stocks, stockViewModel: stockViewModel).tag(1)
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("🧩🧩")
                    }
            }
            LaunchScreenView()
                .opacity(showLaunch ? 1 : 0)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        LaunchScreenView.shouldAnimate = false
                        withAnimation() {
                            self.showLaunch = false
                        }
                    }
                }
        }
    }
}


class ObserverCoreData : ObservableObject {
    @Published var coreStocks = Set<ListStockData>()

    static var shared = ObserverCoreData()

    init() {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "StockData")
        
        do {
            let res = try context.fetch(req)
            for i in res as! [NSManagedObject] {
                
                let nam = i.value(forKey: "name") as! String
                let sym = i.value(forKey: "symbol") as! String
                let pri = i.value(forKey: "price") as! String
                let pC = i.value(forKey: "priceChange") as? String ?? "Unknown change"
                let id = i.value(forKey: "id") as! UUID
                
                self.coreStocks.insert(ListStockData(id: id, symbol: sym, name: nam, price: pri, priceChange: pC))
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func add(id: UUID, name: String, symbol: String, price: String, priceChange: String) {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        let entity = NSEntityDescription.insertNewObject(forEntityName: "StockData", into: context)
        entity.setValue(name, forKey: "name")
        entity.setValue(symbol, forKey: "symbol")
        entity.setValue(price, forKey: "price")
        entity.setValue(priceChange, forKey: "priceChange")
        entity.setValue(id, forKey: "id")
        
        do {
            try context.save()
            self.coreStocks.insert(ListStockData(symbol: symbol, name: name, price: price, priceChange: priceChange))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func delete(id: UUID) {
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "StockData")
        
        do {
            let res = try context.fetch(req)
            for i in res as! [NSManagedObject] {
                
                if i.value(forKey: "id") as! UUID == id {
                    context.delete(i)
                    try context.save()
                    
                    for i in 0..<coreStocks.count {
                        if coreStocks[coreStocks.index(coreStocks.startIndex, offsetBy: i)].id == id {
                            coreStocks.remove(at: coreStocks.index(coreStocks.startIndex, offsetBy: i))
                            return
                        }
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
