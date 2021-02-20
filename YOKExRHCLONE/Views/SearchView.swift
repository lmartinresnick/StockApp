//
//  SearchView.swift
//  YOKExRHCLONE
//
//  Created by Luke Martin-Resnick on 2/18/21.
//

import SwiftUI

struct SearchView: View {
    
    @Binding var stocks: Set<ListStockData>
    @ObservedObject var stockViewModel = StockViewModel()
    @State private var showCancelButton: Bool = false
    @State var selectedItem: AddItem?
    @State private var timerRunning = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Search")
                    .font(Font.custom("CapsuleSansText", size: 35))
                    .padding(.top, 50)
                    .padding(.horizontal)
                SearchBar(text: $stockViewModel.query, onTextChanged: searchFetch)
                    .padding(.horizontal)
                    .navigationBarHidden(showCancelButton)
                        .animation(.default)
                List {
                    ForEach(stockViewModel.dataSource) { searchResults in
                        ForEach(searchResults.items ?? []) { item in
                            SearchResults(searchResult: item, selectedItem: self.$selectedItem, stocks: self.$stocks)
                        }
                    }
                }
                    
                .listStyle(InsetListStyle())
         
                .resignKeyboardOnDragGesture()
            }
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea([.bottom,.horizontal,.leading])
        }
        
        
            
            
    }
        
    func searchFetch(for query: String) {
        if(!timerRunning) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                stockViewModel.fetchStock()
                timerRunning = false
            }
            timerRunning = true
        }
    }
    
}


extension UIApplication {
    func endEditing(_ force: Bool) {
        self.windows
            .filter{$0.isKeyWindow}
            .first?
            .endEditing(force)
    }
}

struct ResignKeyboardOnDragGesture: ViewModifier {
    var gesture = DragGesture().onChanged{_ in
        UIApplication.shared.endEditing(true)
    }
    func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

extension View {
    func resignKeyboardOnDragGesture() -> some View {
        return modifier(ResignKeyboardOnDragGesture())
    }
}

struct AddSection: Identifiable {
    
    var id = UUID()
    var header: String?
    var items: [AddItem]?
    
}

struct AddItem: Identifiable, Equatable {
    
    var id = UUID()
    var title: String?
    var subtitle: String?
    
    var alreadyInList: Bool
    
}
